-------------------------------------------------------------------------------
-- mason
-------------------------------------------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup()

-------------------------------------------------------------------------------
-- lsp config
-------------------------------------------------------------------------------
vim.lsp.config("*", {
  capabilities = require("cmp_nvim_lsp").default_capabilities()
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("vimls")
vim.lsp.enable("clangd")
vim.lsp.enable("bashls")
vim.lsp.enable("erlangls")

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
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({count=1,  float=true, severity={min=vim.diagnostic.severity.INFO}}) end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({count=-1, float=true, severity={min=vim.diagnostic.severity.INFO}}) end, opts)
    vim.keymap.set("n", "]D", function() vim.diagnostic.jump({count=vim._maxint,  wrap=false}) end, opts)
    vim.keymap.set("n", "[D", function() vim.diagnostic.jump({count=-vim._maxint, wrap=false}) end, opts)
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
    ["<CR>"] = cmp.mapping.confirm({select=true}),
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
