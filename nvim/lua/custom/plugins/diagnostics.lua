return {
  -- Beautiful diagnostics list
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'TroubleToggle',
    keys = {
      { '<leader>xx', '<cmd>TroubleToggle<cr>', desc = 'Toggle Trouble' },
      { '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', desc = 'Workspace Diagnostics' },
      { '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', desc = 'Document Diagnostics' },
    },
    opts = {},
  },

  -- Fancy inline diagnostics (toggle with <leader>l)
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    event = 'LspAttach',
    config = function()
      require('lsp_lines').setup()

      -- Start with normal virtual text
      vim.diagnostic.config { virtual_text = true, virtual_lines = false }

      -- Toggle between modes
      vim.keymap.set('n', '<leader>l', function()
        local config = vim.diagnostic.config()
        if config.virtual_text then
          vim.diagnostic.config { virtual_text = false, virtual_lines = true }
        else
          vim.diagnostic.config { virtual_text = true, virtual_lines = false }
        end
      end, { desc = 'Toggle LSP Lines' })
    end,
  },
}
