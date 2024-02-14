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
            text = 'tree',
          },
          {
            filetype = 'Outline',
            text = 'outline',
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
    opts = function(_, opts)
      local icons = require('lazyvim.config').icons

      local function lsp_servers(msg)
        msg = msg or 'Inactive'
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })

        if next(clients) == nil then
          if type(msg) == 'boolean' or #msg == 0 then
            return ''
          end
          return msg
        end

        local client_names = {}
        local ignored_clients = { 'null-ls', 'copilot' }

        for _, client in pairs(clients) do
          if not vim.tbl_contains(ignored_clients, client.name) then
            table.insert(client_names, client.name)
          end
        end

        return table.concat(client_names, ',')
      end

      local function fg(name)
        return function()
          ---@type { foreground?: number }?
          local hl = vim.api.nvim_get_hl_by_name(name, true)
          return hl and hl.foreground and { fg = string.format('#%06x', hl.foreground) }
        end
      end

      opts.options = vim.tbl_deep_extend('force', opts.options, {
        component_separators = { '', '' },
        section_separators = { '', '' },
      })
      opts.sections = vim.tbl_deep_extend('force', opts.sections, {
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
        lualine_c = {
          {
            'diff',
            padding = { left = 1, right = 0 },
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
          },
          {
            'filetype',
            icon_only = true,
            padding = { left = 1, right = 0 },
          },
          {
            'filename',
            path = 1,
            symbols = { modified = '', readonly = '', unnamed = '' },
          },
          {
            'diagnostics',
            padding = { left = 0, right = 1 },
            symbols = {
              info = icons.diagnostics.Info,
              error = icons.diagnostics.Error,
              hint = icons.diagnostics.Hint,
              warn = icons.diagnostics.Warn,
            },
          },
          {
            function()
              return require('nvim-navic').get_location()
            end,
            cond = function()
              return package.loaded['nvim-navic'] and require('nvim-navic').is_available()
            end,
          },
        },
        lualine_x = {
          {
            function()
              return require('noice').api.status.command.get()
            end,
            color = fg('Statement'),
            cond = function()
              return package.loaded['noice'] and require('noice').api.status.command.has()
            end,
          },
          {
            function()
              return require('noice').api.status.mode.get()
            end,
            color = fg('Constant'),
            cond = function()
              return package.loaded['noice'] and require('noice').api.status.mode.has()
            end,
          },
          {
            require('lazy.status').updates,
            cond = require('lazy.status').has_updates,
            color = fg('Special'),
          },
          {
            lsp_servers,
            padding = { left = 0, right = 1 },
          },
        },
        lualine_y = { { 'location' } },
        lualine_z = {
          function()
            return os.date('%R')
          end,
        },
      })
    end,
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
    'dashboard-nvim',
    opts = function(_, opts)
      local logo = [[
                  __
 ___     ___    ___   __  __ /\_\    ___ ___
  / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\
  /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \
    \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\
    \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/

      ]]

      opts.config.header = vim.split(logo, '\n')
    end,
  },
}
