-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local noremap = require('config.keymaps.util').noremap

noremap('n', '0', '^')
noremap('n', '^', '0')

if vim.g.vscode then
  require('config.keymaps.vscode')
end
