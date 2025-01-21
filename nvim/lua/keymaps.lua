vim.g.mapleader = ' '

vim.keymap.set('n', '<leader>n', ':bn<cr>')
vim.keymap.set('n', '<leader>p', ':bp<cr>')
vim.keymap.set('n', '<leader>x', ':bd<cr>')

-- markdown preview
vim.keymap.set('n', '<leader>mp', ':MarkdownPreviewToggle')

-- yank to clipboard
vim.keymap.set('n', '<leader>y', '[[+y]')

-- open terminal
vim.keymap.set('n', '<leader>t', ':vsplit | terminal<cr>')

-- close window pane
-- TODO: This implementaion needs to be completed
-- vim.keymap.set('n', '<leader>c', '<cr>wo')
