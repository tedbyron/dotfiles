return {
  {
    'bufferline.nvim',
    opts = {
      options = {
        -- indicator = { style = 'none' }
        offsets = {
          {
            filetype = 'neo-tree',
            text = '樹',
          },
        },
        -- separator_style = { '', '' }
        show_buffer_close_icons = false,
        tab_size = 12,
      },
    },
  },
  {
    'indent-blankline.nvim',
    enabled = false,
  },
  {
    'lualine.nvim',
    opts = {
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = function(str)
              return str:sub(1, 1)
            end,
          },
        },
        lualine_b = {
          {
            'branch',
            icons_enabled = false,
          },
        },
        lualine_y = {
          {
            'location',
            padding = { left = 0, right = 1 },
          },
        },
        lualine_z = {
          function()
            return os.date('%R')
          end,
        },
      },
    },
  },
  {
    'mini.indentscope',
    opts = function(_, opts)
      opts.draw = {
        animation = require('mini.indentscope').gen_animation.none(),
      }
    end,
  },
}
