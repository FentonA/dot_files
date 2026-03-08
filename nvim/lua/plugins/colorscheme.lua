return {
  { "rebelot/kanagawa.nvim" },
  { "rose-pine/neovim", name = "rose-pine" },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
        transparent_mode = false,
        italic = {
          strings = true,
          comments = true,
          operators = false,
          folds = true,
        },
      })
      vim.cmd("colorscheme gruvbox")
    end,
  },
  { "zenbones-theme/zenbones.nvim", dependencies = { "rktjmp/lush.nvim" } },
}
