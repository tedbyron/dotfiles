return {
  {
    'neo-tree.nvim',
    opts = {
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_hidden = false,
          never_show = {
            '.git',
            '.DS_Store',
            'thumbs.db',
          },
        },
      },
    },
  },
}
