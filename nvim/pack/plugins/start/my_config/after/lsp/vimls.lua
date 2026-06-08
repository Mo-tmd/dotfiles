---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local dotfiles = os.getenv("WorkDotfiles") or os.getenv("Dotfiles")
    if dotfiles and vim.startswith(bufname, dotfiles) then
      on_dir(dotfiles)
    else
      local root_markers = {'.git'}
      on_dir(vim.fs.root(bufnr, root_markers))
    end
  end
}
