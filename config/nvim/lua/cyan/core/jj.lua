-- jj (Jujutsu) keymaps for the "curate commits file-by-file" workflow.
--
-- Mental model:
--   1. <leader>jn  -- create an empty "slot" commit before @ (prompt for msg).
--   2. Open files you want in that slot.
--   3. <leader>js  -- squash THIS file from @ into the slot (@-). Non-interactive.
--      <leader>jS  -- same, hunk-level (scm-record TUI scoped to this file).
--   4. Repeat <leader>jn for the next logical commit.
--   5. <leader>jc  -- when @ holds the leftover, describe and start fresh @.

local function jj_run(args, opts)
  opts = opts or {}
  vim.system({ 'jj', unpack(args) }, { text = true }, function(out)
    vim.schedule(function()
      local label = 'jj ' .. table.concat(args, ' ')
      if out.code ~= 0 then
        vim.notify(label .. '\n' .. (out.stderr or ''), vim.log.levels.ERROR)
        return
      end
      local msg = (out.stderr ~= '' and out.stderr) or out.stdout or ''
      vim.notify(label .. '\n' .. msg:gsub('\n+$', ''), vim.log.levels.INFO)
      pcall(function()
        require('gitsigns').refresh()
      end)
      if opts.reload_buffers then
        vim.cmd 'silent! checktime'
      end
      if opts.on_success then
        opts.on_success()
      end
    end)
  end)
end

local function current_file()
  local path = vim.fn.expand '%:p'
  if path == '' or vim.bo.buftype ~= '' then
    vim.notify('No real file in current buffer', vim.log.levels.WARN)
    return nil
  end
  return path
end

local function jj_term(cmd, on_exit)
  local ok_snacks = pcall(require, 'snacks')
  if not ok_snacks or not _G.Snacks or not Snacks.terminal then
    vim.notify('Snacks.terminal not available', vim.log.levels.ERROR)
    return
  end
  local term = Snacks.terminal(cmd, {
    win = { position = 'float', border = 'rounded', width = 0.9, height = 0.9 },
    auto_close = true,
    start_insert = true,
  })
  if on_exit and term and term.buf then
    vim.api.nvim_create_autocmd('TermClose', {
      buffer = term.buf,
      once = true,
      callback = function()
        vim.schedule(on_exit)
      end,
    })
  end
end

local map = vim.keymap.set

map('n', '<leader>jn', function()
  -- Capture buffer path BEFORE the prompt so it survives focus changes.
  local path = vim.fn.expand '%:p'
  local include_file = path ~= '' and vim.bo.buftype == ''
  vim.ui.input({ prompt = 'jj commit message: ' }, function(msg)
    if not msg or msg == '' then
      return
    end
    jj_run({ 'new', '-B', '@', '--no-edit', '-m', msg }, {
      on_success = include_file and function()
        jj_run({ 'squash', '--from', '@', '--into', '@-', path }, { reload_buffers = true })
      end or nil,
    })
  end)
end, { desc = 'JJ: new commit before @ (incl. current file)' })

map('n', '<leader>js', function()
  local p = current_file()
  if not p then
    return
  end
  jj_run({ 'squash', '--from', '@', '--into', '@-', p }, { reload_buffers = true })
end, { desc = 'JJ: squash current file -> @-' })

map('n', '<leader>jS', function()
  local p = current_file()
  if not p then
    return
  end
  jj_term({ 'jj', 'squash', '--from', '@', '--into', '@-', '-i', p }, function()
    pcall(function()
      require('gitsigns').refresh()
    end)
    vim.cmd 'silent! checktime'
  end)
end, { desc = 'JJ: squash current file -> @- (hunks)' })

map('n', '<leader>jc', function()
  vim.ui.input({ prompt = 'jj commit message for @: ' }, function(msg)
    if not msg or msg == '' then
      return
    end
    -- `jj commit -m` sets @'s description AND starts a fresh empty @ on top.
    jj_run({ 'commit', '-m', msg }, { reload_buffers = true })
  end)
end, { desc = 'JJ: commit @ (describe + new @)' })

map('n', '<leader>jr', function()
  local p = current_file()
  if not p then
    return
  end
  -- `jj restore <path>` defaults to --from @- --into @, dropping @'s changes
  -- to this file. Reload the buffer so we see the restored content.
  jj_run({ 'restore', p }, { reload_buffers = true })
end, { desc = 'JJ: restore current file (discard @ changes)' })

map('n', '<leader>ju', function()
  jj_run({ 'undo' }, { reload_buffers = true })
end, { desc = 'JJ: undo last op' })
