---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local root_markers = {'.git'}
    on_dir(DotfilesRoot(bufnr) or vim.fs.root(bufnr, root_markers))
  end
}
