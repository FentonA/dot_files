require('obsidian').setup {
  workspaces = {
    {
      name = 'Foxwell Mind Palace',
      path = '~/Desktop/Foxwell/',
    },
  },

  completion = {
    nvim_cmp = true,
    min_chars = 2,
    new_notes_location = 'current_dir',
  },

  mappings = {
    ['<leader>of'] = {
      action = function()
        return require('obsidian').util.gf_passthrough()
      end,
      opts = { noremap = false, expr = true, buffer = true },
    },
  },
}
