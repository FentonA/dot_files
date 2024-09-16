-- You can add your own plugins here or in other files in this directory!ins
-- I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

return {
  -- General Plugins
  'tpope/vim-dispatch',
  'tpope/vim-fugitive',

  {
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = 'markdown',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre " .. vim.fn.expand("~") .. "/path/to/my-vault/*.md",
    --   "BufNewFile " .. vim.fn.expand("~") .. "/path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      'nvim-lua/plenary.nvim',

      -- See below for full list of optional dependencies 👇
    },
    opts = {
      workspaces = {
        {
          name = 'personal',
          path = '~/Desktop/Foxwell',
        },
      },

      -- See below for full list of options 👇
    },
  },

  -- Rails-specific Plugins
  {
    'tpope/vim-rails',
    ft = { 'ruby' },
    dependencies = { 'tpope/vim-bundler' }, -- Optional
  },
  {
    'vim-ruby/vim-ruby',
    ft = { 'ruby' },
  },

  -- DAP (Debug Adapter Protocol) Plugins
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
    },
  },

  -- Snippets
  {
    'L3MON4D3/LuaSnip',
    dependencies = {
      'rafamadriz/friendly-snippets',
      config = function()
        require('luasnip.loaders.from_vscode').lazy_load()
      end,
    },
  },

  -- Testing
  {
    'vim-test/vim-test',
    keys = {
      { '<leader>t', ':TestNearest<CR>', desc = 'Run Nearest Test' },
      { '<leader>T', ':TestFile<CR>', desc = 'Run Current File Tests' },
      { '<leader>a', ':TestSuite<CR>', desc = 'Run All Tests' },
    },
  },

  -- Symbols Outline
  {
    'simrat39/symbols-outline.nvim',
    cmd = 'SymbolsOutline',
    opts = {},
  },

  -- Projectionist
  {
    'tpope/vim-projectionist',
    ft = { 'ruby', 'eruby', 'haml' },
  },

  -- Add other plugins below...
}
