-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local noremap = require('config.keymaps.util').noremap

noremap('n', '0', '^')
noremap('n', '^', '0')

vim.keymap.set({ 'n', 'x' }, '<leader>w', '<C-w>')

if vim.g.vscode then
  vim.keymap.set({ 'n', 'x' }, '<Tab>', '%')
  require('config.keymaps.vscode')
end
