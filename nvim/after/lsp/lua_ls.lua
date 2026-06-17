---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local root_markers = {
      '.emmyrc.json',
      '.luarc.json',
      '.luarc.jsonc',
      '.luacheckrc',
      '.stylua.toml',
      'stylua.toml',
      'selene.toml',
      'selene.yml',
      '.git'
    }
    on_dir(DotfilesRoot(bufnr) or vim.fs.root(bufnr, root_markers))
  end,

  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      local dotfiles = os.getenv("WorkDotfiles") or os.getenv("Dotfiles")
      if dotfiles and vim.startswith(path, dotfiles) then
        local lua_settings = client.config.settings.Lua or {}
        ---@cast lua_settings table
        client.config.settings.Lua = vim.tbl_deep_extend('force', lua_settings, {
          runtime = {
            version = 'LuaJIT',
            path = {
              'lua/?.lua',
              'lua/?/init.lua',
            },
          },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file('lua', true),
          },
        })
      end
    end
  end
}
