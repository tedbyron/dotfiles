local lazy_path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local not_vscode = not vim.g.vscode

if not vim.loop.fs_stat(lazy_path) then
  -- stylua: ignore
  vim.fn.system({
    'git', 'clone', 'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    '--filter=blob:none',
    lazy_path,
  })
end

vim.opt.rtp:prepend(lazy_path)

require('lazy').setup({
  spec = {
    { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },
    { import = 'lazyvim.plugins.extras.coding.copilot', enabled = not_vscode },
    { import = 'lazyvim.plugins.extras.formatting.prettier', enabled = not_vscode },
    { import = 'lazyvim.plugins.extras.lang.json', enabled = not_vscode },
    { import = 'lazyvim.plugins.extras.lang.typescript', enabled = not_vscode },
    { import = 'lazyvim.plugins.extras.linting.eslint', enabled = not_vscode },
    { import = 'plugins' },
  },
  defaults = {
    lazy = true,
    version = false,
  },
  install = { colorscheme = { 'dracula' } },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        -- 'matchit',
        -- 'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})
