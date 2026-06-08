---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local dotfiles = os.getenv("WorkDotfiles") or os.getenv("Dotfiles")
    if dotfiles and vim.startswith(bufname, dotfiles) then
      on_dir(dotfiles)
    else
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
      on_dir(vim.fs.root(bufnr, root_markers))
    end
  end,

  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      local dotfiles = os.getenv("WorkDotfiles") or os.getenv("Dotfiles")
      if dotfiles and vim.startswith(path, dotfiles) then
        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
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
  end,
  settings = {
    Lua = {},
  },
}
