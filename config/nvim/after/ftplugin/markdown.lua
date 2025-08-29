-- Text wrap
vim.opt_local.wrap = true -- Wrap text
vim.opt_local.linebreak = true -- Line break on whole words

-- Allow j/k when navigating wrapped lines
vim.keymap.set('n', 'j', 'gj', { buffer = 0 })
vim.keymap.set('n', 'k', 'gk', { buffer = 0 })

-- Spell check
vim.opt_local.spell = true

