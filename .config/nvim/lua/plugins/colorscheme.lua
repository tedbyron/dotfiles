return {
  {
    'mofiqul/dracula.nvim',
    lazy = false,
    opts = function(_, opts)
      local bg = require('dracula').colors().bg

      opts.show_end_of_buffer = false
      opts.transparent_bg = false
      opts.overrides = {
        NeoTreeNormal = { bg = bg },
        NeoTreeNormalNC = { bg = bg },
      }
    end,
    priority = 1000,
  },
  { 'LazyVim/LazyVim', opts = { colorscheme = { 'dracula' } } },
  { 'tokyonight.nvim', enabled = false },
  { 'catppuccin', enabled = false },
}
