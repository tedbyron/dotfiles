local not_vscode = not vim.g.vscode

return {
  { 'LuaSnip', enabled = not_vscode },
  { 'friendly-snippets', enabled = not_vscode },
  { 'nvim-cmp', enabled = not_vscode },
  { 'cmp-nvim-lsp', enabled = not_vscode },
  { 'cmp-buffer', enabled = not_vscode },
  { 'cmp-path', enabled = not_vscode },
  { 'cmp_luasnip', enabled = not_vscode },
  { 'cmp_luasnip', enabled = not_vscode },
}
