local format = string.format

local cmd = vim.cmd
local fn = vim.fn
local nvim_command = vim.api.nvim_command

local packer_path = fn.stdpath('data') .. '/site/pack/packer/start'

function ensure (user, repo)
  local install_path = format('%s/%s', packer_path, repo)

  if fn.empty(fn.glob(install_path)) == 1 then
    nvim_command(format('!gh repo clone %s/%s %s -- --depth 1', user, repo, install_path))
    nvim_command(format('packadd %s', repo))

    local doc_path = install_path .. '/doc'

    if fn.empty(fn.glob(doc_path)) == 0 then
      cmd('helptags ' .. doc_path)
    end
  end
end

ensure('wbthomason', 'packer.nvim')
ensure('lewis6991', 'impatient.nvim')
ensure('rktjmp', 'hotpot.nvim')

require('impatient')
require('hotpot').setup({
  provide_require_fennel = true,
  compiler = {
    modules = {
      correlate = true
    }
  }
})
require('init')
