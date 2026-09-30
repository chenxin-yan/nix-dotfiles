return {
  'jake-stewart/multicursor.nvim',
  branch = '1.0',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local mc = require 'multicursor-nvim'

    mc.setup()

    local set = vim.keymap.set

    -- Add or skip cursor above/below the main cursor.
    set({ 'n', 'v' }, '<up>', function()
      mc.lineAddCursor(-1)
    end, { desc = 'Add a cursor above' })
    set({ 'n', 'v' }, '<down>', function()
      mc.lineAddCursor(1)
    end, { desc = 'Add a cursor below' })
    set({ 'n', 'v' }, '<leader><up>', function()
      mc.lineSkipCursor(-1)
    end, { desc = 'Skip a cursor above' })
    set({ 'n', 'v' }, '<leader><down>', function()
      mc.lineSkipCursor(1)
    end, { desc = 'Skip a cursor below' })

    -- Add or skip adding a new cursor by matching word/selection
    set({ 'n', 'v' }, '<leader>]', function()
      mc.matchAddCursor(1)
    end, { desc = 'Add a cursor at next match' })
    set({ 'n', 'v' }, '<leader>}', function()
      mc.matchSkipCursor(1)
    end, { desc = 'Skip a cursor at next match' })
    set({ 'n', 'v' }, '<leader>[', function()
      mc.matchAddCursor(-1)
    end, { desc = 'Add a cursor at previous match' })
    set({ 'n', 'v' }, '<leader>{', function()
      mc.matchSkipCursor(-1)
    end, { desc = 'Skip a cursor at previous match' })

    -- Add all matches in the document
    set({ 'n', 'v' }, '<leader>cA', mc.matchAllAddCursors, { desc = 'Add cursor at all matches' })

    -- Rotate the main cursor.
    set({ 'n', 'v' }, '<left>', mc.nextCursor, { desc = 'Next cursor' })
    set({ 'n', 'v' }, '<right>', mc.prevCursor, { desc = 'Prevous cursor' })

    -- Delete the main cursor.
    set({ 'n', 'v' }, '<leader>cx', mc.deleteCursor, { desc = 'Delete main cursor' })

    -- Add and remove cursors with control + left click.
    set('n', '<c-leftmouse>', mc.handleMouse, { desc = 'Add or remove cursor' })

    -- Easy way to add and remove cursors using the main cursor.
    set({ 'n', 'v' }, '<c-q>', mc.toggleCursor, { desc = 'Toggle multicursor' })

    -- Clone every cursor and disable the originals.
    set({ 'n', 'v' }, '<leader><c-q>', mc.duplicateCursors, { desc = 'Duplicate cursors' })

    set('n', '<esc>', function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      elseif mc.hasCursors() then
        mc.clearCursors()
      else
        -- Default <esc> handler.
        vim.cmd 'nohlsearch'
      end
    end)

    -- bring back cursors if you accidentally clear them
    set('n', '<leader>crr', mc.restoreCursors, { desc = 'Restore cursors' })

    -- Align cursor col
    set('n', '<leader>ca', mc.alignCursors, { desc = 'Align cursors' })

    -- Split visual selections by regex.
    set('v', 'S', mc.splitCursors)

    -- Append/insert for each line of visual selections.
    set('v', 'I', mc.insertVisual)
    set('v', 'A', mc.appendVisual)

    -- match new cursors within visual selections by regex.
    set('v', 'M', mc.matchCursors)

    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, 'MultiCursorCursor', { link = 'Cursor' })
    hl(0, 'MultiCursorVisual', { link = 'Visual' })
    hl(0, 'MultiCursorSign', { link = 'SignColumn' })
    hl(0, 'MultiCursorDisabledCursor', { link = 'Visual' })
    hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
    hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
  end,
}

