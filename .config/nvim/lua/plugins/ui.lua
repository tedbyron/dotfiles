return {
  {
    'bufferline.nvim',
    opts = {
      options = {
        indicator = { style = 'none' },
        separator_style = 'thin',
        show_buffer_close_icons = false,
        tab_size = 12,
      },
    },
  },
  {
    'lualine.nvim',
    opts = function(_, opts)
      local icons = LazyVim.config.icons

      local function lsp_servers(msg)
        msg = msg or 'Inactive'
        local clients = vim.lsp.get_clients({ bufnr = 0 })

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

      local function fg(hl_group)
        return function()
          return { fg = Snacks.util.color(hl_group) }
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
          LazyVim.lualine.root_dir(),
          {
            'diagnostics',
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          {
            'filetype',
            icon_only = true,
            separator = '',
            padding = { left = 1, right = 0 },
          },
          { LazyVim.lualine.pretty_path() },
          -- {
          --   'diff',
          --   padding = { left = 1, right = 0 },
          --   symbols = {
          --     added = icons.git.added,
          --     modified = icons.git.modified,
          --     removed = icons.git.removed,
          --   },
          -- },
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
          Snacks.profiler.status(),
          {
            function()
              return require('noice').api.status.command.get()
            end,
            cond = function()
              return package.loaded['noice'] and require('noice').api.status.command.has()
            end,
            color = fg('Statement'),
          },
          {
            function()
              return require('noice').api.status.mode.get()
            end,
            cond = function()
              return package.loaded['noice'] and require('noice').api.status.mode.has()
            end,
            color = fg('Constant'),
          },
          {
            function()
              return require('dap').status()
            end,
            cond = function()
              return package.loaded['dap'] and require('dap').status() ~= ''
            end,
            color = fg('Debug'),
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
    'noice.nvim',
    opts = {
      lsp = {
        hover = { silent = true },
      },
    },
  },
  {
    'snacks.nvim',
    opts = {
      dashboard = {
        preset = {
          header = [[
                 __
___     ___    ___   __  __ /\_\    ___ ___
 / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\
 /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \
  \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\
   \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/
          ]],
        },
      },
    },
  },
}
