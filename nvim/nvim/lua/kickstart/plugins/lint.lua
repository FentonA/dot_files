-- lua/custom/plugins/lint.lua

return {
  {
    -- Linting Plugin
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- Define linters for specific filetypes
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        lua = { 'luacheck' },
        python = { 'flake8' },
        ruby = { 'rubocop' },
        rust = { 'rustfmt', 'clippy' },
        typescript = { 'eslint' },
        javascript = { 'eslint' },
        -- Add more filetypes and their linters as needed
      }

      -- Create an autocommand group for linting
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

      -- Set up autocommands to trigger linting
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          local success, err = pcall(lint.try_lint)
          if not success then
            vim.notify('Linting failed: ' .. err, vim.log.levels.ERROR)
          end
        end,
      })
    end,
  },
}
