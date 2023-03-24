local not_vscode = not vim.g.vscode

-- local function trash(state)
--   local inputs = require('neotree.ui.inputs')
--   local node = state.tree:get_node()
--
--   if node.type == 'message' then
--     return
--   end
--
--   local _, name = require('neo-tree.utils').split_path(node.path)
--   local msg = string.format('Are you sure you want to trash "%s"?', name)
--
--   inputs.confirm(msg, function(confirmed)
--     if not confirmed then
--       return
--     end
--
--     vim.api.nvim_command('silent !trash -F ' .. node.path)
--     require('neo-tree.sources.manager').refresh(state.name)
--   end)
-- end
--
-- local function trash_visual(state, selected_nodes)
--   local inputs = require('neotree.ui.inputs')
--   local paths_to_trash = {}
--
--   for _, node in ipairs(selected_nodes) do
--     if node.type ~= 'message' then
--       table.insert(paths_to_trash, node.path)
--     end
--   end
--
--   local msg = 'Are you sure you want to trash ' .. #paths_to_trash .. ' items?'
--
--   inputs.confirm(msg, function(confirmed)
--     if not confirmed then
--       return
--     end
--
--     for _, path in ipairs(paths_to_trash) do
--       vim.api.nvim_command('silent !trash -F ' .. path)
--     end
--     require('neo-tree.sources.manager').refresh(state.name)
--   end)
-- end

local function tsserver_rename(args)
  local ts_clients = vim.lsp.get_active_clients({ name = 'tsserver' })

  for _, ts_client in ipairs(ts_clients) do
    ts_client.request('workspace/executeCommand', {
      command = '_typescript.applyRenameFile',
      arguments = {
        {
          sourceUri = vim.uri_from_fname(args.source),
          targetUri = vim.uri_from_fname(args.destination),
        },
      },
    })
  end
end

return {
  {
    'neo-tree.nvim',
    enabled = not_vscode,
    opts = {
      default_component_configs = {
        indent = { with_expanders = false },
      },
      events = {
        {
          event = 'file_renamed',
          handler = function(args)
            tsserver_rename(args)
            print(args.source, ' renamed to ', args.destination)
          end,
        },
        {
          event = 'file_moved',
          handler = function(args)
            tsserver_rename(args)
            print(args.source, ' moved to ', args.destination)
          end,
        },
      },
      filesystem = {
        bind_to_cwd = true,
        commands = {
          system_open = function(state)
            local path = state.tree:get_node():get_id()

            vim.api.nvim_command(string.format("silent !open -R '%s'", path))
            vim.api.nvim_command(string.format("silent !xdg-open '%s'", path))
          end,
        },
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
        window = {
          mappings = {
            ['o'] = 'system_open',
          },
        },
      },
    },
  },
  { 'nvim-spectre', enabled = not_vscode },
  {
    'telescope.nvim',
    enabled = not_vscode,
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      config = function() require('telescope').load_extension('fzf') end,
    },
  },
  { 'which-key.nvim', enabled = not_vscode },
  { 'gitsigns.nvim', enabled = not_vscode },
  { 'mini.bufremove', enabled = not_vscode },
  { 'trouble.nvim', enabled = not_vscode },
  {
    'todo-comments.nvim',
    enabled = not_vscode,
    opts = {
      highlight = { pattern = [[.*<(KEYWORDS)\s*]] },
      search = { pattern = [[\b(KEYWORDS)\b]] },
    },
  },
}
