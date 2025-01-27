-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.g.lazygit_floating_window_use_plenary = true
vim.g.lazyvim_picker = 'telescope'
vim.g.loaded_node_provider = false
vim.g.loaded_perl_provider = false
vim.g.loaded_python3_provider = false
vim.g.loaded_ruby_provider = false

vim.opt.scrolloff = 3

if vim.g.vscode then
  vim.opt.timeout = false
end
