-- SQL client. Connection strings hold credentials, so they never live in this
-- repo: they come from ~/.config/nvim/dbs.lua, which is gitignored. See
-- dbs.lua.example for the expected shape.
local sql_ft = { "sql", "mysql", "plsql" }

local function load_connections()
  local path = vim.fn.stdpath("config") .. "/dbs.lua"
  if not vim.uv.fs_stat(path) then
    return {}
  end

  local ok, dbs = pcall(dofile, path)
  if not ok then
    vim.notify("dbs.lua failed to load: " .. tostring(dbs), vim.log.levels.WARN)
    return {}
  end
  if type(dbs) ~= "table" then
    vim.notify("dbs.lua must return a table of connections", vim.log.levels.WARN)
    return {}
  end
  return dbs
end

return {
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },

  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = "tpope/vim-dadbod",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Toggle DBUI" },
    },
    init = function()
      local data_path = vim.fn.stdpath("data")

      vim.g.dbs = load_connections()
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
      vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_use_nvim_notify = true
      -- Don't fire the query on every :w -- a heavy one can hang nvim. Run with <leader>S.
      vim.g.db_ui_execute_on_save = false
    end,
  },

  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = "tpope/vim-dadbod",
    ft = sql_ft,
    init = function()
      -- Let blink's omni source drive completion instead of nvim's bundled sql plugin.
      vim.g.omni_sql_default_compl_type = "syntax"
      vim.g.loaded_sql_completion = true
    end,
  },

  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "kristijanhusak/vim-dadbod-completion" },
    opts = {
      sources = {
        per_filetype = {
          sql = { "dadbod", "buffer", "snippets" },
          mysql = { "dadbod", "buffer", "snippets" },
          plsql = { "dadbod", "buffer", "snippets" },
        },
        providers = {
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = { ensure_installed = { "sql" } },
  },
}
