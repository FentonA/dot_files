return {
  {
    "obsidian-nvim/obsidian.nvim",
    ft = "markdown",
    cmd = {
      "ObsidianToday",
      "ObsidianYesterday",
      "ObsidianTomorrow",
      "ObsidianNew",
      "ObsidianSearch",
      "ObsidianQuickSwitch",
      "ObsidianBacklinks",
      "ObsidianTags",
      "ObsidianFollowLink",
      "ObsidianOpen",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "Foxwell",
          path = "~/Documents/Foxwell",
        },
      },

      daily_notes = {
        folder = "Daily Notes",
        date_format = "%Y-%m-%d",
        default_tags = {},
      },

      new_notes_location = "notes_subdir",
      notes_subdir = "inbox",

      disable_frontmatter = false,
      completion = {
        nvim_cmp = false,
        min_chars = 2,
      },

      picker = {
        name = "telescope.nvim",
      },

      follow_url_func = function(url)
        vim.fn.jobstart({ "xdg-open", url }, { detach = true })
      end,
    },
    keys = {
      { "<leader>od", "<cmd>ObsidianToday<cr>",       desc = "Today's daily note" },
      { "<leader>oy", "<cmd>ObsidianYesterday<cr>",   desc = "Yesterday's daily note" },
      { "<leader>oT", "<cmd>ObsidianTomorrow<cr>",    desc = "Tomorrow's daily note" },
      { "<leader>on", "<cmd>ObsidianNew<cr>",         desc = "New note (to inbox)" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>",      desc = "Search vault" },
      { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch note" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>",   desc = "Backlinks" },
      { "<leader>ot", "<cmd>ObsidianTags<cr>",        desc = "Tags" },
      { "<leader>oo", "<cmd>ObsidianOpen<cr>",        desc = "Open in Obsidian app" },
    },
  },
}
