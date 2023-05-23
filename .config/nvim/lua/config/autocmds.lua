-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

if not vim.g.vscode then
  vim.api.nvim_create_autocmd({ 'VimResized' }, {
    callback = function()
      vim.cmd('tabdo wincmd =')
    end,
  })
end
