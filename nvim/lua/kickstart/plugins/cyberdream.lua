-- Define reusable color variables
local colors = {
  background = 'NONE', -- Transparent background
  foreground = '#E0E0E0', -- Main text color
  comment = '#A1A1A1', -- Soft grey for comments
  keyword = '#FFD700', -- Bright golden for keywords
  function_name = '#9A9A9A', -- Light grey for functions
  string = '#A1D6E6', -- Cyan for strings
  variable_name = '#A1E6B1', -- Light green for variable names
  identifier = '#D1A1D6', -- Magenta for identifiers
  operator = '#9B7FD1', -- Purple for operators
  type = '#8F8F8F', -- Grey for types
  diff_add = '#A1D6A4', -- Green for added lines
  diff_change = '#FFD700', -- Yellow for changed lines
  diff_delete = '#D1A1D6', -- Magenta for deleted lines
  diff_text = '#A1D6E6', -- Cyan for changed text
}

require('cyberdream').setup {
  transparent = true,
  italic_comments = true,
  hide_fillchars = true,
  borderless_telescope = false,
  terminal_colors = true,
  cache = false,

  theme = {
    variant = 'dark',
    saturation = 0.8,
    highlights = {
      Normal = { fg = colors.foreground, bg = colors.background },
      Comment = { fg = colors.comment, bg = colors.background, italic = true },
      Keyword = { fg = colors.keyword, bg = colors.background, bold = true }, -- Keywords color
      Function = { fg = colors.function_name, bg = colors.background, italic = true }, -- Function names color
      String = { fg = colors.string, bg = colors.background, bold = true },
      Identifier = { fg = colors.identifier, bg = colors.background, bold = true },
      Variable = { fg = colors.variable_name, bg = colors.background, bold = true }, -- Variable names color
      Operator = { fg = colors.operator, bg = colors.background, bold = true },
      Type = { fg = colors.type, bg = colors.background, bold = true },
      Directory = { fg = colors.operator, bg = colors.background, bold = true },
      DiffAdd = { fg = colors.diff_add, bg = 'NONE', bold = true },
      DiffChange = { fg = colors.diff_change, bg = 'NONE', bold = true },
      DiffDelete = { fg = colors.diff_delete, bg = 'NONE', bold = true },
      DiffText = { fg = colors.diff_text, bg = 'NONE', bold = true },
    },
    colors = {
      bg = colors.background,
      green = colors.diff_add,
      magenta = colors.identifier,
      cyan = colors.string,
      purple = colors.operator,
      yellow = colors.keyword,
    },
  },
  extensions = {
    telescope = true,
    notify = true,
    mini = true,
  },
}

-- Additional custom highlights for keywords, function names, and variables
vim.cmd [[
  highlight Keyword guifg=#FFD700 guibg=NONE gui=bold
  highlight Function guifg=#9A9A9A guibg=NONE gui=italic
  highlight Identifier guifg=#D1A1D6 guibg=NONE gui=bold
  highlight Variable guifg=#A1E6B1 guibg=NONE gui=bold
]]
