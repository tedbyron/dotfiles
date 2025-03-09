-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

if vim.g.vscode then
  vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
else
  vim.api.nvim_create_autocmd({ 'VimResized' }, {
    callback = function()
      vim.cmd('tabdo wincmd =')
    end,
  })
end
