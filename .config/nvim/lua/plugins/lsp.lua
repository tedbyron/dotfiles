-- :h mason-lspconfig-server-map

return {
  {
    'nvim-lspconfig',
    opts = {
      servers = {
        bashls = {},
        cssls = {},
        -- docker_compose_language_service = {},
        -- dockerls = {},
        -- elixirls = {},
        emmet_ls = {},
        html = {},
        jsonls = {},
        marksman = {},
        nil_ls = {},
        -- prismals = {},
        postgres_lsp = {},
        rust_analyzer = {},
        -- sqls = {},
        svelte = {},
        tailwindcss = {},
        taplo = {},
        tsserver = {},
        volar = {},
        yamlls = {},
      },
    },
  },
  {
    'mason.nvim',
    opts = {
      ensure_installed = {
        'actionlint',
        'bash-language-server',
        -- 'codelldb',
        'css-lsp',
        -- 'docker-compose-language-service',
        -- 'dockerfile-language-server',
        -- 'elixir-ls',
        'emmet-ls',
        'eslint-lsp',
        'eslint_d',
        'html-lsp',
        'json-lsp',
        'lua-language-server',
        'marksman',
        'nil',
        -- 'prisma-language-server',
        'rust-analyzer',
        'shellcheck',
        -- 'sqls',
        'stylua',
        'svelte-language-server',
        'tailwindcss-language-server',
        'taplo',
        'typescript-language-server',
        'vue-language-server',
        'yaml-language-server',
      },
    },
  },
}
