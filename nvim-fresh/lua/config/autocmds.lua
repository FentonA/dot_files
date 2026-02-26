-- Fix gf for Rails partials in ERB files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "eruby", "erb" },
  callback = function()
    vim.opt_local.suffixesadd:prepend(".html.erb")
    vim.opt_local.suffixesadd:prepend(".erb")
    vim.opt_local.includeexpr = "substitute(v:fname, '\\v(.*/)?(.+)', '\\1_\\2', '')"
  end,
})
