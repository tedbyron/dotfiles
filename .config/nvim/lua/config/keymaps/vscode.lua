local util = require('config.keymaps.util')

vim.keymap.set({ 'n', 'x', 'o' }, 'gc', '<Plug>VSCodeCommentary')
vim.keymap.set('n', 'gcc', '<Plug>VSCodeCommentaryLine')

util.noremap_notify('n', '<leader>ea', 'editor.action.quickFix')
util.noremap_notify('n', '<leader>es', 'editor.action.triggerSuggest')
util.noremap_notify('n', '<leader>ef', 'editor.action.formatDocument')
util.noremap_notify_visual('x', '<leader>ef', 'editor.action.formatSelection')
util.noremap_notify('n', '<leader>er', 'editor.action.rename')

util.noremap_notify('n', '<leader>ga', 'git.stage')
util.noremap_notify('n', '<leader>gA', 'git.stageAll')
util.noremap_notify('n', '<leader>gd', 'git.openChange')
util.noremap_notify('n', '<leader>gr', 'git.rename')
util.noremap_notify('n', '<leader>gu', 'git.unstage')
util.noremap_notify_visual({ 'n', 'x' }, '<leader>ghs', 'git.stageSelectedRanges')
util.noremap_notify_visual({ 'n', 'x' }, '<leader>ghu', 'git.unstageSelectedRanges')
util.noremap_notify_visual({ 'n', 'x' }, '<leader>ghr', 'git.revertSelectedRanges')

util.noremap_notify('n', '<leader>un', 'notifications.clearAll')
util.noremap_notify('n', '<leader>ur', 'workbench.action.reloadWindow')

-- TODO: hello
util.noremap_notify('n', ']d', 'editor.action.marker.next')
util.noremap_notify('n', '[d', 'editor.action.marker.prev')
util.noremap_notify('n', ']h', 'workbench.action.editor.nextChange')
util.noremap_notify('n', '[h', 'workbench.action.editor.previousChange')
util.noremap_notify('n', ']t', 'todo-tree.goToNext')
util.noremap_notify('n', '[t', 'todo-tree.goToPrevious')
