return {
  { "tpope/vim-rails", ft = { "ruby", "eruby" } },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "rust", "ruby", "toml", "yaml", "html", "embedded_template",
      })
    end,
  },
}
