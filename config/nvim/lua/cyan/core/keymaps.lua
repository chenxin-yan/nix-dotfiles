-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- clear highlight search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<cr>')

-- Diagnostic/todo keymaps
vim.keymap.set('n', 'X', vim.diagnostic.open_float, { desc = 'Show diagnostic Error messages' })
vim.keymap.del('n', '<c-w>d')
vim.keymap.del('n', '<c-w><c-d>')

--  deleting/paste without yanking the deleted text into the register
vim.keymap.set('x', 'p', '"_dP', { desc = 'Paste in without yanking selected text' })
vim.keymap.set('x', '<leader>p', 'p', { desc = 'Paste in and yank selected text' })
vim.keymap.set({ 'n', 'x' }, 'x', '"_x', { desc = 'Delete without yanking' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<cmd>wincmd h<cr>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<cmd>wincmd l<cr>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<cmd>wincmd j<cr>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<cmd>wincmd k<cr>', { desc = 'Move focus to the upper window' })

-- Keep cursor always in the middle when scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Yanking selection into system clipboard
vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y', { desc = 'Yank into system clipboard' })

-- toggle spellcheck
vim.keymap.set('n', '<leader>us', '<cmd>set invspell<cr>', { desc = 'Toggle [S]pell check' })

-- Split windows
vim.keymap.set('n', '<leader>_', '<cmd>horizontal split<cr>', { desc = 'Horizontal Split' })
vim.keymap.set('n', '<leader>|', '<cmd>vertical split<cr>', { desc = 'Vertical Split' })

-- Tab operations
vim.keymap.set('n', '<leader><C-t>', '<cmd>tabnew<cr>', { desc = 'Create new tab' })
vim.keymap.set('n', '<leader><C-w>', '<cmd>tabc<cr>', { desc = 'Close current tab' })
vim.keymap.set('n', '<C-]>', '<cmd>tabn<cr>', { desc = '[N]ext tab' })
vim.keymap.set('n', '<C-[>', '<cmd>tabp<cr>', { desc = '[P]revious tab' })

-- replace $ and ^ with H and L
vim.keymap.set({ 'n', 'x' }, 'H', '^')
vim.keymap.set({ 'n', 'x' }, 'L', '$')

-- select all keymap
vim.keymap.set('n', '<leader><C-a>', 'gg<s-v>G', { desc = 'Select all' })

-- switch between buffers
vim.keymap.set('n', '<leader><Tab>', '<cmd>b#<cr>', { desc = 'Goto previously opened buffer' })
vim.keymap.set('n', '<C-w>', '<cmd>bprev<cr>', { desc = 'Goto previous buffer' })
vim.keymap.set('n', '<C-e>', '<cmd>bnext<cr>', { desc = 'Goto next buffer' })

-- select pasted text
vim.keymap.set('n', 'gP', '`[v`]', { desc = 'Select Pasted Text' })
