-- Operator API: each mapping returns `g@`, so it takes a motion in normal
-- mode or acts on the selection in visual mode.
local function op(name)
  return function()
    return require('refactoring')[name]()
  end
end

return {
  'ThePrimeagen/refactoring.nvim',
  cmd = 'Refactor',
  dependencies = {
    -- Only needed on Neovim 0.12; 0.13 ships vim.async.
    'lewis6991/async.nvim',
    'romus204/tree-sitter-manager.nvim',
  },
  keys = {
    { '<leader>rf', op 'extract_func', mode = { 'n', 'x' }, expr = true, desc = 'Extract [F]unction' },
    { '<leader>rF', op 'extract_func_to_file', mode = { 'n', 'x' }, expr = true, desc = 'Extract [F]unction to file' },
    { '<leader>rv', op 'extract_var', mode = { 'n', 'x' }, expr = true, desc = 'Extract [V]ariable' },
    { '<leader>rI', op 'inline_func', mode = { 'n', 'x' }, expr = true, desc = '[I]nline function' },
    { '<leader>ri', op 'inline_var', mode = { 'n', 'x' }, expr = true, desc = '[I]nline variable' },
  },
}
