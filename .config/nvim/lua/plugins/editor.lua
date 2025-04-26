return {
  {
    "todo-comments.nvim",
    opts = {
      highlight = { pattern = [[.*<(KEYWORDS)\s*]] },
      search = { pattern = [[\b(KEYWORDS)\b]] },
    },
  },
  -- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
  {
    "snacks.nvim",
    opts = function(_, opts)
      opts.explorer = vim.tbl_deep_extend("force", opts.explorer or {}, {
        -- TODO
      })

      opts.files = vim.tbl_deep_extend("force", opts.buffers or {}, {
        hidden = true,
        follow = true,
        exclude = { ".git" },
      })

      return opts
    end,
  },
}
