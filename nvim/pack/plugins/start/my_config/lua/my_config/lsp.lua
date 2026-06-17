-------------------------------------------------------------------------------
-- mason
-------------------------------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup()

-------------------------------------------------------------------------------
-- lsp root_dir
-------------------------------------------------------------------------------
-- Resolves a fugitive:// URI to the real file path, or returns nil.
local function resolve_fugitive_bufname(bufname)
  if bufname:find("^fugitive://") then
    return vim.fn["fugitive#Real"](bufname)
  end
end

-- Override vim.fs.root to resolve fugitive:// URIs to real file paths so LSP
-- finds the correct root_dir.
local orig_root = vim.fs.root
---@diagnostic disable-next-line: duplicate-set-field
vim.fs.root = function(source, marker)
  if type(source) == "number" then -- lsp only uses buffer number as source.
    local bufname = vim.api.nvim_buf_get_name(source)
    source = resolve_fugitive_bufname(bufname) or source
  end
  return orig_root(source, marker)
end

-- Returns the outer dotfiles directory if bufnr is inside it, nil otherwise.
function DotfilesRoot(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  bufname = resolve_fugitive_bufname(bufname) or bufname
  local dotfiles = os.getenv("WorkDotfiles") or os.getenv("Dotfiles")
  if dotfiles and vim.startswith(bufname, dotfiles) then
    return dotfiles
  end
end

-------------------------------------------------------------------------------
-- lsp config
-------------------------------------------------------------------------------
vim.lsp.enable("lua_ls")
vim.lsp.enable("vimls")
vim.lsp.enable("clangd")
vim.lsp.enable("bashls")
vim.lsp.enable("erlangls")
vim.lsp.enable("jdtls")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = {buffer=event.buf}

    -- navigation
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gtd", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "gdc", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gri", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "grr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gO", vim.lsp.buf.document_symbol, opts)

    -- diagnostics
    local on_jump = function() vim.diagnostic.open_float({focus=false}) end
    local severity = {min=vim.diagnostic.severity.INFO}
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({count=1,  on_jump=on_jump, severity=severity}) end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({count=-1, on_jump=on_jump, severity=severity}) end, opts)
    vim.keymap.set("n", "]D", function() vim.diagnostic.jump({count=vim._maxint,  on_jump=on_jump, severity=severity, wrap=false}) end, opts)
    vim.keymap.set("n", "[D", function() vim.diagnostic.jump({count=-vim._maxint, on_jump=on_jump, severity=severity, wrap=false}) end, opts)
    vim.keymap.set("n", "<C-W>d", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<C-W><C-D>", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>dt", function() vim.diagnostic.enable(not vim.diagnostic.is_enabled({bufnr=0}), {bufnr=0}) end, opts)

    -- info
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set({"i","s"}, "<C-S>", vim.lsp.buf.signature_help, opts)

    -- actions
    vim.keymap.set("n", "grn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "grx", vim.lsp.codelens.run, opts)
    vim.keymap.set({"n","x"}, "gra", vim.lsp.buf.code_action, opts)
    vim.keymap.set({"n","x"}, "gq", function() vim.lsp.buf.format({async = true}) end, opts)
  end,
})

-------------------------------------------------------------------------------
-- luasnip
-------------------------------------------------------------------------------
local paths = {os.getenv("Dotfiles").."/nvim/snippets"}
if (os.getenv("WorkDotfiles") ~= nil) then
  table.insert(paths, os.getenv("WorkDotfiles").."/nvim/snippets")
end
require("luasnip.loaders.from_vscode").lazy_load({paths=paths})

local luasnip = require("luasnip")
luasnip.setup({
  delete_check_events = {"TextChanged","TextChangedI"},
  link_children = true
})

-------------------------------------------------------------------------------
-- cmp
-------------------------------------------------------------------------------
vim.lsp.config("*", {
  capabilities = require("cmp_nvim_lsp").default_capabilities()
})

local cmp = require("cmp")
cmp.setup({
  completion = {
    keyword_length = 2
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end
  },
  sources = {
    {name="luasnip"},
    {name="nvim_lsp"}
  },
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({select=false}),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<Tab>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end,
      {"i", "s"}
    ),
    ["<S-Tab>"] = cmp.mapping(
      function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
      end,
      {"i", "s"}
    )
  }
})
