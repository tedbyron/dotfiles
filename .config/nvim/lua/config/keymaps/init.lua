-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local noremap = require("config.keymaps.util").noremap

noremap("n", "0", "^")
noremap("n", "^", "0")
noremap("n", "/", "/\\v")

for _, mode in pairs({ "n", "v", "o" }) do
  noremap(mode, "<Tab>", vim.api.nvim_eval(string.format('maparg("%%", "%s")', mode)))
end

if vim.g.vscode then
  require("config.keymaps.vscode")
end
