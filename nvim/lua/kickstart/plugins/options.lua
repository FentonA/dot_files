vim.cmd 'colorscheme everforest'

vim.opt.termguicolors = true
require('bufferline').setup {}
-- Better diagnostic display
vim.diagnostic.config {
  virtual_text = {
    prefix = '●',
    source = 'if_many',
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    source = 'always',
    border = 'rounded',
  },
}

-- Pretty signs in gutter
local signs = {
  Error = '󰅚 ',
  Warn = '󰀪 ',
  Hint = '󰌶 ',
  Info = ' ',
}

for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
