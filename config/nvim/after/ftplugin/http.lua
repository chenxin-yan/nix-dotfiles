local function map(lhs, rhs, desc)
  vim.keymap.set('n', '<leader>r' .. lhs, rhs, { desc = desc, buffer = 0 })
end
map('b', "<cmd>lua require('kulala').scratchpad()<cr>", 'Open scratchpad')
map('c', "<cmd>lua require('kulala').copy()<cr>", 'Copy as cURL')
map('C', "<cmd>lua require('kulala').from_curl()<cr>", 'Paste from curl')
map('g', "<cmd>lua require('kulala').download_graphql_schema()<cr>", 'Download GraphQL schema')
map('i', "<cmd>lua require('kulala').inspect()<cr>", 'Inspect current request')
map('n', "<cmd>lua require('kulala').jump_next()<cr>", 'Jump to next request')
map('p', "<cmd>lua require('kulala').jump_prev()<cr>", 'Jump to previous request')
map('r', "<cmd>lua require('kulala').replay()<cr>", 'Replay the last request')
map('s', "<cmd>lua require('kulala').run()<cr>", 'Send the request')
map('S', "<cmd>lua require('kulala').show_stats()<cr>", 'Show stats')
map('t', "<cmd>lua require('kulala').toggle_view()<cr>", 'Toggle headers/body')

require('which-key').add { '<leader>r', group = 'Rest', buffer = 0 , icon = "󰒲 "}

