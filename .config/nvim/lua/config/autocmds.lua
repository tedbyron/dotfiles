-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local not_vscode = not vim.g.vscode

if not_vscode then
  vim.api.nvim_create_autocmd({ 'VimResized' }, {
    callback = function()
      vim.cmd('tabdo wincmd =')
    end,
  })
end
