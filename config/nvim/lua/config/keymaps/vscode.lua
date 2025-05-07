local noremap = require("config.keymaps.util").noremap
local vscode = require("vscode-neovim")

---@param mode string|table
---@param lhs string
---@param rhs string
local function noremap_action(mode, lhs, rhs)
  noremap(mode, lhs, function() vscode.action(rhs) end)
end

noremap_action("n", "<C-h>", "workbench.action.focusLeftGroup")
noremap_action("n", "<C-j>", "workbench.action.focusBelowGroup")
noremap_action("n", "<C-k>", "workbench.action.focusAboveGroup")
noremap_action("n", "<C-l>", "workbench.action.focusRightGroup")

noremap_action("n", "<Leader> ", "workbench.action.quickOpen")
noremap_action("n", "<Leader>;", "workbench.action.showCommands")
vim.keymap.set("n", "<Leader>w", "<C-w>")

vim.keymap.set({ "n", "x", "o" }, "gc", "<Plug>VSCodeCommentary")
vim.keymap.set("n", "gcc", "<Plug>VSCodeCommentaryLine")

noremap_action("n", "<Leader>bd", "workbench.action.closeActiveEditor")
noremap_action("n", "<Leader>bo", "workbench.action.closeOtherEditors")

noremap_action("n", "<Leader>es", "editor.action.triggerSuggest")
noremap_action("n", "<Leader>ef", "editor.action.formatDocument")
noremap_action("x", "<Leader>ef", "editor.action.formatSelection")
noremap_action("n", "<Leader>er", "editor.action.rename")

noremap_action("n", "<Leader>ga", "git.stage")
noremap_action("n", "<Leader>gA", "git.stageAll")
noremap_action("n", "<Leader>gd", "git.openChange")
noremap_action("n", "<Leader>gr", "git.rename")
noremap_action("n", "<Leader>gu", "git.unstage")
noremap_action({ "n", "x" }, "<Leader>ghs", "git.stageSelectedRanges")
noremap_action({ "n", "x" }, "<Leader>ghu", "git.unstageSelectedRanges")
noremap_action({ "n", "x" }, "<Leader>ghr", "git.revertSelectedRanges")

noremap_action("n", "<Leader>uN", "notifications.showList")
noremap_action("n", "<Leader>un", "notifications.clearAll")
noremap_action("n", "<Leader>ur", "workbench.action.reloadWindow")

noremap_action("n", "]d", "editor.action.marker.next")
noremap_action("n", "[d", "editor.action.marker.prev")
noremap_action("n", "]h", "workbench.action.editor.nextChange")
noremap_action("n", "[h", "workbench.action.editor.previousChange")
noremap_action("n", "]t", "todo-tree.goToNext")
noremap_action("n", "[t", "todo-tree.goToPrevious")
noremap_action("n", "]b", "workbench.action.nextEditor")
noremap_action("n", "[b", "workbench.action.previousEditor")

noremap_action({ "n", "x" }, "gsdt", "editor.emmet.action.removeTag")
noremap_action("n", "gsrtt", "editor.emmet.action.updateTag")
noremap_action("x", "gsat", "editor.emmet.action.wrapWithAbbreviation")
