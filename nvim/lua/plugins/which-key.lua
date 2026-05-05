return {
  {
    "folke/which-key.nvim",
    opts = {
      preset = "modern",
      delay = 300,
      spec = {
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>c", group = "code" },
        { "<leader>b", group = "buffer" },
        { "<leader>w", group = "window" },
        { "<leader>x", group = "diagnostics" },
        { "<leader>r", group = "rust" },
        { "<leader>t", group = "test" },
        { "<leader>o", group = "obsidian" },
      },
    },
  },
}
