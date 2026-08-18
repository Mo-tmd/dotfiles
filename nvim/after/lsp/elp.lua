local function deduplicate_references(items)
  local paths = vim.iter(items)
    :map(function(item) return item.filename end)
    :totable()
  local filtered = {}
  for _, item in ipairs(items) do
    local file = item.filename
    local real_file = vim.uv.fs_realpath(file)
    if real_file ~= file and vim.tbl_contains(paths, real_file) then
      -- File is a symlink and the real file already exists in items.
    else
      table.insert(filtered, item)
    end
  end
  return filtered
end

local function on_list(list)
  local items = deduplicate_references(list.items)
  vim.fn.setqflist({}, " ", {title=list.title, items=items})
  vim.cmd("botright copen")
end

---@type vim.lsp.Config
return {
  root_markers = {".elp.toml", "rebar.config", "erlang.mk", ".git"},
  settings = {
    elp = {
      diagnostics = {
        onSave = {
          enable = true
        }
      }
    }
  },
  on_attach =
    function(_, bufnr)
      vim.keymap.set("n",
                     "grr",
                     function() vim.lsp.buf.references(nil, {on_list=on_list}) end,
                     {buffer = bufnr}
                    )
    end
}
