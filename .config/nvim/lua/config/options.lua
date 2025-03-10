-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.g.loaded_node_provider = false
vim.g.loaded_perl_provider = false
vim.g.loaded_python3_provider = false
vim.g.loaded_ruby_provider = false

vim.opt.scrolloff = 3

if vim.g.vscode then
  vim.opt.timeout = false
end
