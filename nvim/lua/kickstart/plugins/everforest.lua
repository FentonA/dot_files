require("everforest").setup({
     bakground = "medium",
    transparent_background_level = 0,
    italics = true,
    disable_italic_comments = false,
    on_highlights = function(hl, _)
      hl["@string.special.symbol.ruby"] = { link = "@field" }
    end,-- Your config here
  })
