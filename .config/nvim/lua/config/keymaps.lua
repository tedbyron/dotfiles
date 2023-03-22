-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local function map(mode, lhs, rhs, opts)
  local keys = require('lazy.core.handler').handlers.keys

  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

map({ 'n', 'v' }, '<Tab>', '%')
