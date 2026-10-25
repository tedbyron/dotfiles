-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.g.loaded_node_provider = false
vim.g.loaded_perl_provider = false
vim.g.loaded_python3_provider = false
vim.g.loaded_ruby_provider = false
vim.g.snacks_animate = false

vim.o.scrolloff = 3
vim.o.tabstop = 4

if vim.g.vscode then
  vim.o.timeout = false
end

if vim.env.SSH_CONNECTION then
  vim.g.clipboard = "osc52"
  vim.opt.clipboard = "unnamedplus"
end
