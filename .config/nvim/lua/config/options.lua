-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local g = vim.g
local opt = vim.opt

g.lazygit_floating_window_use_plenary = true
g.loaded_node_provider = false
g.loaded_perl_provider = false
g.loaded_python3_provider = false
g.loaded_ruby_provider = false

if g.neovide then
  g.neovide_cursor_animation_length = 0
  g.neovide_floating_blur = false
end

opt.scrolloff = 3

if g.vscode then opt.timeout = false end
