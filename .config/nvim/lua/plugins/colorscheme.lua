return {
  {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    opts = function(_, opts)
      local bg = require('gruvbox').colors().bg

      opts.show_end_of_buffer = false
      opts.transparent_bg = false
      opts.overrides = {

        NeoTreeNormal = { bg = bg },
        NeoTreeNormalNC = { bg = bg },
      }
    end,
    priority = 1000,
  },
  { 'LazyVim/LazyVim', opts = { colorscheme = { 'gruvbox' } } },
  { 'tokyonight.nvim', enabled = false },
  { 'catppuccin', enabled = false },
}
