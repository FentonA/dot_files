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

vim.keymap.set('n', '<Leader>dl', "<cmd>lua require'dap'.step_into()<CR>", { desc = 'Debugger step into' })
vim.keymap.set('n', '<Leader>dj', "<cmd>lua require'dap'.step_over()<CR>", { desc = 'Debugger step over' })
vim.keymap.set('n', '<Leader>dk', "<cmd>lua require'dap'.step_out()<CR>", { desc = 'Debugger step out' })
vim.keymap.set('n', '<Leader>dc', "<cmd>lua require'dap'.continue()<CR>", { desc = 'Debugger continue' })
vim.keymap.set('n', '<Leader>db', "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = 'Debugger toggle breakpoint' })
vim.keymap.set(
  'n',
  '<Leader>dd',
  "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
  { desc = 'Debugger set conditional breakpoint' }
)
vim.keymap.set('n', '<Leader>de', "<cmd>lua require'dap'.terminate()<CR>", { desc = 'Debugger reset' })
vim.keymap.set('n', '<Leader>dr', "<cmd>lua require'dap'.run_last()<CR>", { desc = 'Debugger run last' })

-- rustaceanvim
vim.keymap.set('n', '<Leader>dt', "<cmd>lua vim.cmd('RustLsp testables')<CR>", { desc = 'Debugger testables' })
