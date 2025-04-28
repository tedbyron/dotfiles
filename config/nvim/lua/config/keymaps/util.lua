local M = {}

---@param mode string|table
---@param lhs string
---@param rhs string | function
---@param opts table?
function M.noremap(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_deep_extend("force", opts or {}, { noremap = true }))
end

return M
