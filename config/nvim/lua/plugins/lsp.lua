-- :h mason-lspconfig-server-map

return {
  {
    "nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
        emmet_ls = {},
        html = {},
      },
    },
  },
  {
    "mason.nvim",
    opts = function(_, opts) 
      vim.list_extend(opts.ensure_installed, {
        "actionlint",
        "bash-language-server",
        "emmet-ls",
        "html-lsp",
        "lua-language-server",
        "shellcheck",
      })
    end,
  },
}
