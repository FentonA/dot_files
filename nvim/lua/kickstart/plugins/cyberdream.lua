-- ~/.config/nvim/lua/kickstart/plugins/cyberdream.lua
require('cyberdream').setup {
  transparent = true, -- Transparent background for the clean look
  italic_comments = true, -- Italics on comments for a soft feel
  hide_fillchars = true, -- Remove unnecessary characters like borders
  borderless_telescope = false, -- Disable borderless for Telescope to add borders
  terminal_colors = true, -- Terminal colors that blend in
  cache = false, -- No cache for immediate feedback on changes

  theme = {
    variant = 'dark', -- Automatically switch to light/dark mode based on system
    saturation = 0.8, -- Slightly higher saturation for a more vibrant feel
    highlights = {
      Normal = { fg = '#E0E0E0', bg = 'NONE' }, -- Lighter grey text for better visibility
      Comment = { fg = '#A1A1A1', bg = 'NONE', italic = true }, -- Soft grey comments
      Keyword = { fg = '#FFD700', bg = 'NONE', bold = true }, -- Bold golden keywords for contrast
      Function = { fg = '#9A9A9A', bg = 'NONE', italic = true }, -- Light function names
      String = { fg = '#A1D6E6', bg = 'NONE', bold = true }, -- Bold cyan for strings to pop
      Identifier = { fg = '#D1A1D6', bg = 'NONE', bold = true }, -- Bold magenta for identifiers
      Operator = { fg = '#9B7FD1', bg = 'NONE', bold = true }, -- Bold purple operators for emphasis
      Type = { fg = '#8F8F8F', bg = 'NONE', bold = true }, -- Type declarations in bold to stand out
    },

    -- Custom color overrides for a relaxed lo-fi theme
    colors = {
      bg = 'NONE', -- Transparent background for seamless look
      green = '#A1D6A4', -- Soft green for calmness
      magenta = '#D1A1D6', -- Light purple-magenta for accent
      cyan = '#A1D6E6', -- Cyan accents for futuristic look
      purple = '#9B7FD1', -- Muted purple for subtle elegance
      yellow = '#FFD700', -- Bright yellow to highlight important text
    },
  },

  -- Extensions to enable for a smooth experience
  extensions = {
    telescope = true, -- Telescope for fuzzy searching (with border)
    notify = true, -- Notifications that match the theme
    mini = true, -- Mini plugin for added utilities
  },
}
