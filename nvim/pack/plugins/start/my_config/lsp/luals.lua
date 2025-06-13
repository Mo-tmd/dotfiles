return {
  cmd = {"lua-language-server"},
  filetypes = {"lua"},
  root_dir = function(bufnr, cb)
    local root_markers = {
      ".luarc.json",
      ".luarc.jsonc",
      ".luacheckrc",
      ".stylua.toml",
      "stylua.toml",
      "selene.toml",
      "selene.yml",
      ".git",
    }
    cb(MyLspRootDir(bufnr, root_markers))
  end,
  settings = {
    Lua = {
      runtime = {version="LuaJIT"},
      diagnostics = {
        globals = {"vim"}
      },
      workspace = {
        checkThirdParty = false,
        library = {vim.env.VIMRUNTIME}
      }
    }
  },
  before_init = function(init_params, config)
     table.insert(config.settings.Lua.workspace.library, config.root_dir)
  end
}
