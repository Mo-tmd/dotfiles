-------------------------------------------------------------------------------
-- Load all lua scripts
-------------------------------------------------------------------------------
require('my_lua/lsp')

-------------------------------------------------------------------------------
-- Yanky
-------------------------------------------------------------------------------
require("yanky").setup({
    highlight = {on_put=false, on_yank=false}
})
vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set({"n","x"}, "gp", "<Plug>(YankyGPutAfter)")
vim.keymap.set({"n","x"}, "gP", "<Plug>(YankyGPutBefore)")

vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")

vim.keymap.set({"n","x"}, "y", "<Plug>(YankyYank)")

-------------------------------------------------------------------------------
-- User Interface
-------------------------------------------------------------------------------
-- Print a table in a Scratch buffer
local function print_to_buffer(arg)
    -- Create a buffer and write to it
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, arg)

    -- Open the buffer in a new split window
    vim.api.nvim_command("vsplit")
    vim.api.nvim_command("buffer " .. buf)
end

local function string_to_table(str)
    local tab = {}
    for line in str:gmatch("[^\r\n]+") do
        table.insert(tab, line)
    end

    return tab
end

-- Print any type of argument in a Scratch buffer.
-- Can be used to print tables for instance
function Print(arg)
    -- First convert arg to a multiline string
    local multiline_string = vim.inspect(arg)

    -- Then convert the multiline string to a table of strings
    local strings = string_to_table(multiline_string)

    print_to_buffer(strings)
end

-- Execute any command and print output in a Scratch buffer
function ExecuteCommand(...)
    local command = table.concat({...}, " ")
    print("Command:", command)
    local output = vim.api.nvim_exec(command, true)
    print_to_buffer(string_to_table(output))
end

vim.cmd("command! -nargs=* Cmd lua ExecuteCommand(<f-args>)")

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- A Reload all system dotfiles and vim scripts.
vim.cmd("command! -nargs=0 Saf lua SourceAllFiles()")

function SourceAllFiles()
    vim.fn.system("saf")
    vim.api.nvim_command("so ~/dotfiles/nvim/init.vim")
    vim.api.nvim_command("so ~/dotfiles/nvim/lua/init.lua")
end
