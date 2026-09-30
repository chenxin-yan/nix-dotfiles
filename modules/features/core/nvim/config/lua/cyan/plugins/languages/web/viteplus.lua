-- Vite+ projects lint (`vp lint --lsp`) and format (`vp fmt`, via Conform, Markdown
-- included) with the workspace's own node_modules/.bin/vp, so install dependencies
-- first and keep lint/fmt settings in the root vite.config.ts. A project opts in by
-- depending on vite-plus; plain Vite and other projects keep standalone Oxc/Biome/Prettier.
local M = {}

function M.root(source)
  -- Package configs may only contain build/test settings; use the workspace's lint/fmt config.
  local root = vim.fs.root(source, { { 'pnpm-workspace.yaml', 'pnpm-lock.yaml', 'package-lock.json', 'yarn.lock', 'bun.lock', 'bun.lockb' }, 'package.json' })
  if not root then
    return
  end
  local ok, package = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(root .. '/package.json'), '\n'))
  end)
  if ok and type(package) == 'table' then
    for _, key in ipairs { 'dependencies', 'devDependencies' } do
      local deps = package[key]
      if type(deps) == 'table' and type(deps['vite-plus']) == 'string' then
        return root
      end
    end
  end
end

function M.oxlint(config)
  local standalone_root = config.root_dir
  config.root_dir = function(bufnr, on_dir)
    local root = M.root(bufnr)
    if root then
      on_dir(root)
    else
      standalone_root(bufnr, on_dir)
    end
  end
  config.cmd = function(dispatchers, client_config)
    local root = client_config.root_dir and M.root(client_config.root_dir)
    if root then
      return vim.lsp.rpc.start({ root .. '/node_modules/.bin/vp', 'lint', '--lsp' }, dispatchers, { cwd = root })
    end
    return dofile(assert(vim.api.nvim_get_runtime_file('lsp/oxlint.lua', false)[1])).cmd(dispatchers, client_config)
  end
  return config
end

-- Vite+ RC removed the Oxc wrappers. Override the shared formatter so Markdown follows too.
function M.formatter(bufnr)
  local root = M.root(bufnr)
  if root then
    return {
      command = root .. '/node_modules/.bin/vp',
      prepend_args = { 'fmt' },
      cwd = function()
        return root
      end,
    }
  end
end

return M
