local util = require('config.keymaps.util')

for _, mode in pairs({ 'n', 'v', 'o' }) do
  util.noremap(mode, '<Tab>', vim.api.nvim_eval(string.format('maparg("%%", "%s")', mode)))
end

util.noremap_notify('n', '<C-h>', 'workbench.action.focusLeftGroup')
util.noremap_notify('n', '<C-j>', 'workbench.action.focusBelowGroup')
util.noremap_notify('n', '<C-k>', 'workbench.action.focusAboveGroup')
util.noremap_notify('n', '<C-l>', 'workbench.action.focusRightGroup')

util.noremap_notify('n', '<Leader> ', 'workbench.action.quickOpen')
util.noremap_notify('n', '<Leader>;', 'workbench.action.showCommands')
vim.keymap.set('n', '<Leader>w', '<C-w>')

vim.keymap.set({ 'n', 'x', 'o' }, 'gc', '<Plug>VSCodeCommentary')
vim.keymap.set('n', 'gcc', '<Plug>VSCodeCommentaryLine')

util.noremap_notify('n', '<Leader>ea', 'editor.action.quickFix')
util.noremap_notify('n', '<Leader>es', 'editor.action.triggerSuggest')
util.noremap_notify('n', '<Leader>ef', 'editor.action.formatDocument')
util.noremap_notify_visual('x', '<Leader>ef', 'editor.action.formatSelection')
util.noremap_notify('n', '<Leader>er', 'editor.action.rename')

util.noremap_notify('n', '<Leader>ga', 'git.stage')
util.noremap_notify('n', '<Leader>gA', 'git.stageAll')
util.noremap_notify('n', '<Leader>gd', 'git.openChange')
util.noremap_notify('n', '<Leader>gr', 'git.rename')
util.noremap_notify('n', '<Leader>gu', 'git.unstage')
util.noremap_notify_visual({ 'n', 'x' }, '<Leader>ghs', 'git.stageSelectedRanges')
util.noremap_notify_visual({ 'n', 'x' }, '<Leader>ghu', 'git.unstageSelectedRanges')
util.noremap_notify_visual({ 'n', 'x' }, '<Leader>ghr', 'git.revertSelectedRanges')

util.noremap_notify('n', '<Leader>un', 'notifications.clearAll')
util.noremap_notify('n', '<Leader>ur', 'workbench.action.reloadWindow')

util.noremap_notify('n', ']d', 'editor.action.marker.next')
util.noremap_notify('n', '[d', 'editor.action.marker.prev')
util.noremap_notify('n', ']h', 'workbench.action.editor.nextChange')
util.noremap_notify('n', '[h', 'workbench.action.editor.previousChange')
util.noremap_notify('n', ']t', 'todo-tree.goToNext')
util.noremap_notify('n', '[t', 'todo-tree.goToPrevious')
util.noremap_notify('n', ']b', 'workbench.action.nextEditor')
util.noremap_notify('n', '[b', 'workbench.action.previousEditor')
