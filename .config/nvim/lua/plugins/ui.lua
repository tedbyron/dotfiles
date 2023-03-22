return {
  {
    'nvim-notify',
    opts = {
      stages = 'fade',
      render = 'default',
    },
  },
  {
    'bufferline.nvim',
    opts = {
      options = {
        indicator = { style = 'none' },
        offsets = {
          {
            filetype = 'neo-tree',
            text = '樹',
          },
          {
            filetype = 'Outline',
            text = '大綱',
          },
        },
        separator_style = 'thin',
        show_buffer_close_icons = false,
        tab_size = 12,
      },
    },
  },
  {
    'lualine.nvim',
    opts = {
      options = {
        component_separators = { '', '' },
        section_separators = { '', '' },
      },
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
    'indent-blankline.nvim',
    enabled = false,
  },
  {
    'mini.indentscope',
    opts = function(_, opts)
      opts.draw = {
        animation = require('mini.indentscope').gen_animation.none(),
      }
    end,
  },
  {
    'alpha-nvim',
    opts = {
      section = {
        header = {
          val = {
            [[                                  __]],
            [[     ___     ___    ___   __  __ /\_\    ___ ___]],
            [[    / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\]],
            [[   /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \]],
            [[   \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
            [[    \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
          },
        },
      },
    },
  },
}
