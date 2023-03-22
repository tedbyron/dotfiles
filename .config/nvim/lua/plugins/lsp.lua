return {
  {
    'mason.nvim',
    opts = {
      ensure_installed = {
        'stylua',
        'shfmt',
        'rnix-lsp',
        'rust-analyzer',
        'svelte-language-server',
        'tailwindcss-language-server',
      },
    },
  },
}
