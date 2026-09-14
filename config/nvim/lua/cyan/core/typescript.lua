local M = {}

local function package_version(root)
  local path = root .. '/node_modules/typescript/package.json'
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end
  local ok, package = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), '\n'))
  end)
  local version = ok and type(package) == 'table' and type(package.version) == 'string' and vim.version.parse(package.version)
  return version or false
end

-- ponytail: synchronous probes, capped at 2s each; resolve asynchronously if startup latency matters.
local function native_binary(root)
  for _, name in ipairs { 'tsc', 'tsgo' } do
    local path = root .. '/node_modules/.bin/' .. name
    if vim.fn.executable(path) == 1 then
      local ok, result = pcall(function()
        return vim.system({ path, '--version' }, { text = true }):wait(2000)
      end)
      local version = ok and result.code == 0 and vim.version.parse(result.stdout or '')
      if version and version.major >= 7 then
        return path
      end
    end
  end
end

-- root_dir supplies a normalized absolute root, retained in the client config for launch revalidation.
-- No selection cache: dependency installs and LSP restarts must re-read the workspace.
function M.resolve(root)
  local override = (vim.g.typescript_toolchains or {})[root]
  if override and override ~= 'native' and override ~= 'legacy' then
    return nil, 'invalid typescript_toolchains override for ' .. root
  end
  local version = package_version(root)
  local legacy = version and (version.major == 5 or version.major == 6)
  if override == 'legacy' or (not override and legacy) then
    local tsdk = root .. '/node_modules/typescript/lib'
    if legacy and vim.fn.filereadable(tsdk .. '/tsserver.js') == 1 then
      return { server = 'vtsls', tsdk = tsdk }
    end
  elseif override == 'native' or version == nil or (version and version.major >= 7) then
    local cmd = native_binary(root)
    if cmd then
      -- Named 'tsgo' so upstream lsp/tsgo.lua supplies filetypes; TS 7 ships the same binary as `tsc`.
      return { server = 'tsgo', cmd = { cmd, '--lsp', '--stdio' } }
    end
  end
  return nil, 'no valid local ' .. (override or 'TypeScript 5/6 SDK or TypeScript 7+ native') .. ' toolchain at ' .. root
end

local upstream_root
function M.root_dir(server)
  return function(bufnr, on_dir)
    -- Reuse upstream lockfile roots, .git/cwd fallback, and Deno exclusions, not its PATH discovery.
    if not upstream_root then
      upstream_root = dofile(assert(vim.api.nvim_get_runtime_file('lsp/vtsls.lua', false)[1])).root_dir
    end
    upstream_root(bufnr, function(root)
      root = vim.fs.normalize(vim.fn.fnamemodify(root, ':p'))
      local selected, err = M.resolve(root)
      if selected and selected.server == server then
        on_dir(root)
      elseif not selected and server == 'vtsls' then
        vim.notify('TypeScript: ' .. err .. '; not attaching (no global/bundled fallback)', vim.log.levels.WARN)
      end
    end)
  end
end

function M.legacy_cmd(dispatchers, config)
  local selected, err = M.resolve(config.root_dir)
  assert(selected and selected.server == 'vtsls', err or 'TypeScript toolchain changed; restart LSP')
  -- Neovim supplies a per-client copy. Mutate its settings, never the shared server config.
  config.settings.typescript.tsdk = selected.tsdk
  return vim.lsp.rpc.start({ 'vtsls', '--stdio' }, dispatchers, { cwd = config.root_dir })
end

function M.cmd(dispatchers, config)
  local selected, err = M.resolve(config.root_dir)
  assert(selected and selected.server == 'tsgo', err or 'TypeScript toolchain changed; restart LSP')
  config.cmd = selected.cmd
  return vim.lsp.rpc.start(config.cmd, dispatchers, { cwd = config.root_dir })
end

return M
