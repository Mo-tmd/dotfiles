-------------------------------------------------------------------------------
-- General
-------------------------------------------------------------------------------
local keymap_settings = {
    preserve_mappings = false,
    omit = {},
}

local lsp = require('lsp-zero').preset({
    float_border = 'rounded',
    call_servers = 'local',
    configure_diagnostics = true,
    setup_servers_on_start = true,
    set_lsp_keymaps = keymap_settings
})

lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({buffer = bufnr})
    vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev({severity={min=vim.diagnostic.severity.INFO}})<CR>', {buffer = true})
    vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next({severity={min=vim.diagnostic.severity.INFO}})<CR>', {buffer = true})
end)

-------------------------------------------------------------------------------
-- lua_ls
-------------------------------------------------------------------------------
local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup(lsp.nvim_lua_ls())

-------------------------------------------------------------------------------
-- erlang_ls
-------------------------------------------------------------------------------
local function root_dir(_)
    return vim.g.ErlangLsRootDir
end

if (vim.g.ErlangLsRootDir) == nil then
    Options = {}
else
    Options = {root_dir = root_dir}
end

lspconfig.erlangls.setup(Options)

-------------------------------------------------------------------------------
-- vim-language-server
-------------------------------------------------------------------------------
local function nvim_dir(_)
    return '/home/user/dotfiles/nvim'
end
lspconfig.vimls.setup({
    root_dir = nvim_dir
})

-------------------------------------------------------------------------------
-- bashls
-------------------------------------------------------------------------------
lspconfig.bashls.setup({})

-------------------------------------------------------------------------------
-- jdtls (Java)
-------------------------------------------------------------------------------
if (vim.g.JdtlsCmd) == nil then
    Options = {}
else
    Options = {cmd = {vim.g.JdtlsCmd}}
end
lspconfig.jdtls.setup(Options)

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
lsp.setup()

-------------------------------------------------------------------------------
-- Cmp and luasnip
-------------------------------------------------------------------------------
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

paths = {os.getenv("Dotfiles") .. "/nvim/snippets"}
if (os.getenv("WorkDotfiles") ~= nil) then
    table.insert(paths, os.getenv("WorkDotfiles") .. "/nvim/snippets")
end
require('luasnip.loaders.from_vscode').lazy_load({paths=paths})

local luasnip = require('luasnip')
Tab = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" })
STab = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" })
local mappings = {
    ['<CR>']    = cmp.mapping.confirm({select=false}),
    ['<Tab>']   = Tab,
    ['<S-Tab>'] = STab,
}

local sources = {
    {name = 'luasnip', keyword_length = 2},
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'buffer', keyword_length = 3}
}

cmp.setup({
    mapping = mappings,
    sources = sources
})

-------------------------------------------------------------------------------
-- Misc
-------------------------------------------------------------------------------
-- Toggle diagnostics
function toggle_diagnostics()
    if vim.diagnostic.is_disabled() then
        vim.diagnostic.enable()
    else
        vim.diagnostic.disable()
    end
end
