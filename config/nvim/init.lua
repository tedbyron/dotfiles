local function ensure_installed(plugin, branch)
  local user, repo = string.match(plugin, "(.+)/(.+)")
  local repo_path = vim.fn.stdpath("data") .. "/lazy/" .. repo

  if not vim.uv.fs_stat(repo_path) then
    vim.notify("Installing " .. plugin .. " " .. branch)
    local out = vim.fn.system({
      "git",
      "clone",
      "https://github.com/" .. plugin .. ".git",
      "--filter=blob:none",
      "--branch=" .. branch,
      repo_path,
    })

    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { "Failed to clone " .. plugin .. ":\n", "ErrorMsg" },
        { out, "WarningMsg" },
        { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
end

local lazy_path = ensure_installed("folke/lazy.nvim", "stable")
local hotpot_path = ensure_installed("rktjmp/hotpot.nvim", "v0.14.8")

vim.opt.rtp:prepend({ hotpot_path, lazy_path })
vim.loader.enable()

require("hotpot").setup({
  build = true,
  clean = true,
  compiler = {
    modules = { correlate = true },
    macros = {
      allowedGlobals = true,
      env = "_COMPILER",
    },
  },
})
require("config.lazy")
