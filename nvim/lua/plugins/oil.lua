return {
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
      },
      float = {
        padding = 2,
        max_width = 80,
        max_height = 30,
      },
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["<C-s>"] = "actions.select_vsplit",
        ["<C-p>"] = "actions.preview",
        ["<C-r>"] = "actions.refresh",
      },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      { "<leader>-", "<cmd>Oil --float<cr>", desc = "Open oil (float)" },
    },
  },
}
