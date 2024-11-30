return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- Define Clippy as a custom linter
      lint.linters.clippy = {
        cmd = 'cargo',
        args = { 'clippy', '--message-format=json' },
        stdin = false,
        append_fname = false,
      }

      -- Define linters for specific filetypes
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        lua = { 'luacheck' },
        python = { 'flake8' },
        ruby = { 'rubocop' },
        rust = { 'clippy' },
        typescript = { 'eslint' },
        javascript = { 'eslint' },
      }

      -- Create an autocommand group for linting
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      local debounce = require('plenary.async.util').debounce
      local debounced_lint = debounce(500, lint.try_lint)

      -- Set up autocommands to trigger linting
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          local success, err = pcall(debounced_lint)
          if not success then
            vim.notify('Linting failed: ' .. err, vim.log.levels.ERROR)
          end
        end,
      })
    end,
  },
}
