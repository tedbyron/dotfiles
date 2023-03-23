-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

if vim.g.vscode then
  vim.keymap.set({ 'x', 'n', 'o' }, 'gc', '<Plug>VSCodeCommentary')
  vim.keymap.set('n', 'gcc', '<Plug>VSCodeCommentaryLine')

  vim.keymap.set('n', '<leader>ca', '<Cmd>call VSCodeNotify("editor.action.triggerSuggest")<CR>', { noremap = true })
  vim.keymap.set('n', '<leader>cf', '<Cmd>call VSCodeNotify("editor.action.formatDocument")<CR>', { noremap = true })
  vim.keymap.set('n', '<leader>co', '<Cmd>call VSCodeNotify("keyboard-quickfix.openQuickFix")<CR>', { noremap = true })
  vim.keymap.set('n', '<leader>cr', '<Cmd>call VSCodeNotify("editor.action.rename")<CR>', { noremap = true })

  vim.keymap.set('n', '<leader>gs', '<Cmd>call VSCodeNotify("git.stage")<CR>', { noremap = true })
  vim.keymap.set('n', '<leader>gu', '<Cmd>call VSCodeNotify("git.unstage")<CR>', { noremap = true })
  vim.keymap.set('n', '<leader>ghs', '<Cmd>call VSCodeNotify("git.stageSelectedRanges")<CR>', { noremap = true })
  vim.keymap.set('n', '<leader>ghu', '<Cmd>call VSCodeNotify("git.unstageSelectedRanges")<CR>', { noremap = true })

  vim.keymap.set('n', '[h', '<Cmd>call VSCodeNotify("editor.action.dirtydiff.previous")<CR>', { noremap = true })
  vim.keymap.set('n', ']h', '<Cmd>call VSCodeNotify("editor.action.dirtydiff.next")<CR>', { noremap = true })
  vim.keymap.set('n', '[d', '<Cmd>call VSCodeNotify("editor.action.marker.prev")<CR>', { noremap = true })
  vim.keymap.set('n', ']d', '<Cmd>call VSCodeNotify("editor.action.marker.next")<CR>', { noremap = true })
end
