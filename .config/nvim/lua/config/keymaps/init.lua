-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local noremap = require("config.keymaps.util").noremap

noremap({ "n", "x", "o" }, "0", "^")
noremap({ "n", "x", "o" }, "^", "0")

for _, mode in pairs({ "n", "v", "o" }) do
  noremap(mode, "<Tab>", vim.api.nvim_eval(string.format('maparg("%%", "%s")', mode)))
end

local function new_lines(command, opposite)
  if vim.v.count <= 1 then
    return command
  end
  return ":<C-u><CR>" .. command .. ".<Esc>m`" .. vim.v.count - 1 .. opposite .. "<Esc>g``s"
end

noremap("n", "o", function() return new_lines("o", "O") end, { silent = true, expr = true })
noremap("n", "O", function() return new_lines("O", "o") end, { silent = true, expr = true })

if vim.g.vscode then
  require("config.keymaps.vscode")
end
