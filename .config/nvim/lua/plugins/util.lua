local not_vscode = not vim.g.vscode

return {
  { 'vim-startuptime', enabled = not_vscode },
  { 'persistence.nvim', enabled = not_vscode },
}
