---@type vim.lsp.Config
return {
  cmd = {"erlang_ls"},
  filetypes = {"erlang"},
  root_markers = {"erlang_ls.config", "rebar.config", "erlang.mk", ".git"}
}
