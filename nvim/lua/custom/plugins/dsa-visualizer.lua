-- ~/.config/nvim/lua/custom/dsa-visualizer.lua
local M = {}

-- Configuration
M.config = {
  -- Path to your HTML visualizer (adjust as needed)
  html_path = vim.fn.stdpath 'config' .. '/lua/custom/plugins/dsa-visualizer.html',
  -- Or use localhost if you're running a server
  base_url = 'file://' .. vim.fn.stdpath 'config' .. '/lua/custom/plugins/dsa-visualizer.html',
  -- base_url = 'http://localhost:3000', -- Uncomment if using local server

  -- API settings (will prompt for API key if not set)
  api_key_file = vim.fn.stdpath 'config' .. 'lua/custom/plugins/claude-api-key.txt',
}

-- Utility function to get API key
local function get_api_key()
  local api_key_file = M.config.api_key_file

  -- Try to read from file first
  local file = io.open(api_key_file, 'r')
  if file then
    local key = file:read('*all'):gsub('%s+', '') -- Remove whitespace
    file:close()
    if key and key ~= '' then
      return key
    end
  end

  -- Prompt user for API key
  local key = vim.fn.input 'Enter Claude API Key (will be saved): sk-'
  if key and key ~= '' then
    key = 'sk-' .. key
    -- Save for future use
    local save_file = io.open(api_key_file, 'w')
    if save_file then
      save_file:write(key)
      save_file:close()
      print('\nAPI key saved to ' .. api_key_file)
    end
    return key
  end

  return nil
end

-- Open visualizer with query
local function open_visualizer(query)
  local encoded_query = vim.fn.shellescape(query)
  local url = M.config.base_url

  if query and query ~= '' then
    -- URL encode the query
    local encoded = query:gsub(' ', '%%20'):gsub('\n', '%%0A')
    url = url .. '?query=' .. encoded
  end

  -- Detect OS and open appropriately
  local open_cmd
  if vim.fn.has 'mac' == 1 then
    open_cmd = 'open'
  elseif vim.fn.has 'unix' == 1 then
    open_cmd = 'xdg-open'
  elseif vim.fn.has 'win32' == 1 then
    open_cmd = 'start'
  else
    vim.notify('Unsupported OS for opening browser', vim.log.levels.ERROR)
    return
  end

  -- Open in browser
  local full_cmd = open_cmd .. ' "' .. url .. '"'
  vim.fn.system(full_cmd)

  vim.notify('🧠 DSA Visualizer opened with: ' .. query, vim.log.levels.INFO)
end

-- Get current line or word under cursor
local function get_current_context()
  local current_line = vim.api.nvim_get_current_line()

  -- If line looks like a problem/algorithm, use it
  if
    current_line:match 'sort'
    or current_line:match 'search'
    or current_line:match 'tree'
    or current_line:match 'graph'
    or current_line:match 'algorithm'
    or current_line:match 'leetcode'
    or current_line:match 'Array'
    or current_line:match 'List'
  then
    return current_line:gsub('^%s*[#/*-]*%s*', '') -- Remove comment markers
  end

  -- Otherwise get word under cursor
  local word = vim.fn.expand '<cword>'
  return word
end

-- Main visualization function
function M.visualize_current_problem()
  local context = get_current_context()
  local problem = vim.fn.input('DSA Problem to visualize: ', context)

  if problem and problem ~= '' then
    -- Add "visualize" prefix if not present
    if not problem:match '^visualize' and not problem:match '^show' and not problem:match '^explain' then
      problem = 'visualize ' .. problem
    end

    open_visualizer(problem)
  else
    vim.notify('No problem specified', vim.log.levels.WARN)
  end
end

-- Custom query function
function M.visualize_custom_query()
  local query = vim.fn.input 'Enter visualization query: '
  if query and query ~= '' then
    open_visualizer(query)
  end
end

-- Visualize selected text
function M.visualize_selection()
  -- Get visual selection
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"

  -- Get selected text
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
  if #lines == 0 then
    vim.notify('No text selected', vim.log.levels.WARN)
    return
  end

  -- Join lines and clean up
  local selected_text = table.concat(lines, ' ')
  selected_text = selected_text:gsub('%s+', ' '):gsub('^%s*', ''):gsub('%s*$', '')

  local problem = vim.fn.input('Visualize selected text: ', selected_text)
  if problem and problem ~= '' then
    if not problem:match '^visualize' then
      problem = 'visualize ' .. problem
    end
    open_visualizer(problem)
  end
end

-- Quick visualize function for preset algorithms
function M.quick_visualize(algorithm)
  open_visualizer(algorithm)
end

-- Setup function (called by plugin config)
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend('force', M.config, opts)

  -- Create data directory if it doesn't exist
  local data_dir = vim.fn.fnamemodify(M.config.api_key_file, ':h')
  vim.fn.mkdir(data_dir, 'p')

  -- Check if HTML file exists
  if not vim.fn.filereadable(M.config.html_path) then
    vim.notify(
      'DSA Visualizer HTML not found at: ' .. M.config.html_path .. '\nPlease save the HTML file there or update the path in config.',
      vim.log.levels.WARN
    )
  end
end

-- Command to quickly access common algorithms
vim.api.nvim_create_user_command('DSAVisualize', function(opts)
  local query = opts.args
  if query == '' then
    M.visualize_current_problem()
  else
    open_visualizer(query)
  end
end, {
  nargs = '*',
  desc = 'Visualize DSA algorithm',
  complete = function()
    return {
      'binary search',
      'merge sort',
      'quick sort',
      'bubble sort',
      'binary tree traversal',
      'breadth first search',
      'depth first search',
      'dijkstra shortest path',
      'sliding window maximum',
      'two pointers technique',
      'dynamic programming fibonacci',
      'backtracking n-queens',
    }
  end,
})

return M
