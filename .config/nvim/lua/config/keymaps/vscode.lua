local util = require('config.keymaps.util')

util.noremap_notify('n', '<leader>ca', 'editor.action.triggerSuggest')
util.noremap_notify('n', '<leader>cf', 'editor.action.formatDocument')
util.noremap_notify_visual('x', '<leader>cf', 'editor.action.formatSelection')
util.noremap_notify('n', '<leader>cr', 'editor.action.rename')

util.noremap_notify('n', '<leader>gs', 'git.stage')
util.noremap_notify('n', '<leader>gu', 'git.unstage')
util.noremap_notify_visual({ 'n', 'x' }, '<leader>ghs', 'git.stageSelectedRanges')
util.noremap_notify_visual({ 'n', 'x' }, '<leader>ghu', 'git.unstageSelectedRanges')

util.noremap_notify('n', '<leader>un', 'notifications.clearAll')
util.noremap_notify('n', '<leader>ur', 'workbench.action.reloadWindow')
util.noremap_notify('n', '<leader>uw', 'editor.action.toggleWordWrap')

util.noremap_notify('n', ']d', 'editor.action.marker.next')
util.noremap_notify('n', '[d', 'editor.action.marker.prev')
util.noremap_notify('n', ']h', 'workbench.action.editor.previousChange')
util.noremap_notify('n', '[h', 'workbench.action.editor.nextChange')
util.noremap_notify('n', ']t', 'todo-tree.goToNext')
util.noremap_notify('n', '[t', 'todo-tree.goToPrevious')
