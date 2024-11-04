-- Autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    require('nvim-autopairs').setup {
      check_ts = true, -- Enables Tree-sitter support
    }

    -- Set up automatic pairing with nvim-cmp
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

    -- Add custom rules for autopairing, especially Ruby
    local npairs = require 'nvim-autopairs'
    npairs.add_rules(require 'nvim-autopairs.rules.endwise')

    local Rule = require 'nvim-autopairs.rule'
    npairs.add_rules {
      -- Autocomplete `do...end` blocks in Ruby
      Rule('do%s$', ' end', 'ruby'):use_regex(true):replace_endpair(function(opts)
        return opts.line:sub(opts.col - 2, opts.col - 1) == 'do' and ' end' or ''
      end),

      -- Automatically add closing `end` for control structures
      Rule('if%s$', ' end', 'ruby'):use_regex(true),
      Rule('def%s$', ' end', 'ruby'):use_regex(true),
      Rule('begin$', ' end', 'ruby'):use_regex(true),
      Rule('unless%s$', ' end', 'ruby'):use_regex(true),
      Rule('while%s$', ' end', 'ruby'):use_regex(true),
      Rule('for%s$', ' end', 'ruby'):use_regex(true),
    }
  end,
}
