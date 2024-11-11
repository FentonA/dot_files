-- File: ~/.config/nvim/lua/kickstart/plugins/ruby_critic.lua

return {
  config = function()
    local function run_ruby_critic()
      local output_dir = 'rubycritic_report' -- The directory where RubyCritic saves reports
      vim.cmd('!rubycritic --format console --path ' .. output_dir)
      vim.notify("RubyCritic analysis complete. Check " .. output_dir .. " for report.")
    end

    -- Create a keybinding to trigger RubyCritic analysis
    vim.api.nvim_set_keymap('n', '<leader>rc', ':lua run_ruby_critic()<CR>', { noremap = true, silent = true })
    
    -- Optionally, set up an autocommand to run RubyCritic on save
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = '*.rb',
      callback = function()
        vim.cmd('!rubycritic --path rubycritic_report')
        vim.notify("RubyCritic analysis complete. Check rubycritic_report for report.")
      end
    })
  end,
}
