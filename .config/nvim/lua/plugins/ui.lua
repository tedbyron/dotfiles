return {
  {
    'bufferline.nvim',
    opts = function(_, opts)
      opts.options.indicator = {
        style = 'none',
      }
      opts.options.separator_style = { '', '' }
      opts.options.show_buffer_close_icons = false
      opts.options.tab_size = 12
    end,
  },
  {
    'indent-blankline.nvim',
    enabled = false,
  },
}
