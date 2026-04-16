return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        win = {
          input = {
            keys = {
              ["I"] = { "toggle_ignored", mode = { "n", "i" } },
              ["H"] = { "toggle_hidden", mode = { "n", "i" } },
            },
          },
          list = {
            keys = {
              ["I"] = "toggle_ignored",
              ["H"] = "toggle_hidden",
            },
          },
        },
        sources = {
          files = {
            hidden = true,
            ignored = false,
          },
          explorer = {
            hidden = true,
            ignored = false,
            watch = true,
            auto_close = false,
          },
        },
      },
    },
    keys = {
      { "<leader>sp", function() Snacks.picker() end, desc = "Snacks Pickers" },
    },
  },
}
