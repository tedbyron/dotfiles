return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = { eslint = {} },
      setup = {
        eslint = function()
          require("lazyvim.util").on_attach(function(client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == "tsserver" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
      },
    },
  },
  {
    'null-ls.nvim',
    opts = function(_, opts)
      local nls = require('null-ls')
      opts.sources[nls.builtins.formatting.prettierd] = nil
    end,
  },
}
