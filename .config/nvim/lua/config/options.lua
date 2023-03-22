-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

vim.g.lazygit_floating_window_use_plenary = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.o.termguicolors = true

opt.scrolloff = 3
-- opt.iskeyword = opt.iskeyword:gsub("-", "")
