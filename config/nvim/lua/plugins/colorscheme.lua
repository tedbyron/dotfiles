return {
  {
    "f4z3r/gruvbox-material.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "gruvbox-material",
        callback = function()
          local colors = require("gruvbox-material.colors").get(vim.o.background, "medium")
          vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { bg = colors.bg5 })
          vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = colors.grey1 })
        end,
      })
    end,
    opts = {
      comments = { italics = false },
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = { "gruvbox-material" } } },
  { "tokyonight.nvim", enabled = false },
  { "catppuccin", enabled = false },
}
