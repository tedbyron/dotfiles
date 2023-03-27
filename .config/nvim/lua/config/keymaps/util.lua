local M = {}

local vscode_command_event_name = 'vscode-command'
local vscode_range_command_event_name = 'vscode-range-command'

local function VSCodeNotify(cmd, ...)
  vim.rpcnotify(vim.g.vscode_channel, vscode_command_event_name, cmd, ...)
end

local function VSCodeNotifyRange(cmd, line1, line2, leaveSelection, ...)
  if not leaveSelection then
    leaveSelection = vim.NIL
  end
  vim.rpcnotify(vim.g.vscode_channel, vscode_range_command_event_name, cmd, line1, line2, 0, 0, leaveSelection, ...)
end

local function VSCodeNotifyRangePos(cmd, line1, line2, pos1, pos2, leaveSelection, ...)
  if not leaveSelection then
    leaveSelection = vim.NIL
  end
  vim.rpcnotify(
    vim.g.vscode_channel,
    vscode_range_command_event_name,
    cmd,
    line1,
    line2,
    pos1,
    pos2,
    leaveSelection,
    ...
  )
end

local function VSCodeNotifyVisual(cmd, leaveSelection, ...)
  local mode = vim.fn.mode()
  if mode == 'V' then
    local start = vim.fn.line('v')
    local finish = vim.fn.line('.')
    VSCodeNotifyRange(cmd, start, finish, leaveSelection, ...)
  elseif mode == 'v' or mode == '\\<C-v>' then
    local start = vim.fn.getpos('v')
    local finish = vim.fn.getpos('.')
    VSCodeNotifyRangePos(cmd, start, finish, leaveSelection, ...)
  else
    VSCodeNotify(cmd, ...)
  end
end

---@param mode string|table
---@param lhs string
---@param rhs string | function
---@param opts table?
function M.noremap(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_deep_extend('force', { noremap = true }, opts or {}))
end

---@param mode string|table
---@param lhs string
---@param rhs string
---@param opts table?
function M.noremap_notify(mode, lhs, rhs, opts)
  M.noremap(mode, lhs, function()
    VSCodeNotify(rhs)
  end, opts)
end

---@param mode string|table
---@param lhs string
---@param rhs string
---@param leaveSelection boolean?
function M.noremap_notify_visual(mode, lhs, rhs, leaveSelection)
  M.noremap(mode, lhs, function()
    VSCodeNotifyVisual(rhs, leaveSelection)
  end)
end

return M
