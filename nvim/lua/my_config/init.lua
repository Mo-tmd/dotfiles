--------------------------------------------------------------------------------
-- Load all lua scripts
--------------------------------------------------------------------------------
require("my_config.lsp")

--------------------------------------------------------------------------------
-- telescope
--------------------------------------------------------------------------------
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<ESC>"] = require('telescope.actions').close,
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
        ["<leader>kb"] = require('telescope.actions').delete_buffer
      },
      n = {
        ["<leader>kb"] = require('telescope.actions').delete_buffer
      }
    },
    layout_config = {
      width = {padding=0},
      height = {padding=0}
    },
    path_display = {
      filename_first = true
    }
  },
  pickers = {
    buffers = {
      sort_mru = true,
      disable_coordinates = true,
      ignore_current_buffer = true
    }
  }
}
require('telescope').load_extension('fzf')

vim.keymap.set(
  'n',
  '<leader>lt',
  '<cmd>Telescope telescope-tabs list_tabs<cr>',
  {silent=true, desc='Telescope: List tabs'}
)

--------------------------------------------------------------------------------
-- yanky
--------------------------------------------------------------------------------
require("yanky").setup({
  ring = {
    history_length = 1000
  },
  highlight = {on_put=false, on_yank=false},
  picker = {
    telescope = {
      use_default_mappings = false,
      mappings = {default = require("yanky.telescope.mapping").put("p")}
    }
  }
})

vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set({"n","x"}, "gp", "<Plug>(YankyGPutAfter)")
vim.keymap.set({"n","x"}, "gP", "<Plug>(YankyGPutBefore)")
vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")
vim.keymap.set({"n","x"}, "y", "<Plug>(YankyYank)")

require("telescope").load_extension("yank_history")
vim.keymap.set("n", "<leader>p", ":Telescope yank_history<CR>", {silent=true})

--------------------------------------------------------------------------------
-- lualine
--------------------------------------------------------------------------------
-- Checks if window is floating, e.g. telescope
local function is_floating_window(win)
  return vim.api.nvim_win_get_config(win).relative ~= ''
end

local merge_tab_names = {
  'MERGED',
  'BASE LOCAL',
  'BASE REMOTE',
  'LOCAL REMOTE',
  'LOCAL BASE REMOTE',
  'LOCAL MERGED',
  'REMOTE MERGED',
  'LOCAL MERGED REMOTE',
}

local tab_name_cache = {}

local function tab_name(tab_id)
  local tabnr = vim.api.nvim_tabpage_get_number(tab_id)
  if vim.g.is_merging and tabnr <= 8 then
    return merge_tab_names[tabnr]
  end

  local win = vim.api.nvim_tabpage_get_win(tab_id)

  -- return old name if the window is floating
  if is_floating_window(win) then
    return tab_name_cache[tab_id] or '[No Name]'
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local name = buf_name ~= '' and vim.fs.basename(buf_name) or '[No Name]'
  if vim.bo[buf].modified then
    name = name .. ' [+]'
  end

  tab_name_cache[tab_id] = name
  return name
end

local gruvbox = require('lualine.themes.gruvbox')
gruvbox.terminal = {
  a = { bg = '#b8bb26', fg = '#282828', gui = 'bold' },
  b = gruvbox.insert.b,
  c = gruvbox.insert.c,
}
gruvbox.command = gruvbox.normal

local filename = {
  'filename',
  file_status = true,
  path = 0,
  symbols = { readonly = ' 🔒' },
  fmt = function(str)
    if vim.bo.buftype == 'terminal' then
      return str:gsub(' 🔒', '')
    end
    return str
  end,
}

require('lualine').setup({
  options = {
    theme = gruvbox,
    component_separators = '',
    section_separators = '',
    always_show_tabline = false,
    disabled_filetypes = {
      statusline = {'nerdtree'},
    },
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {filename},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  inactive_sections = {
    lualine_a = {filename},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  tabline = {
    lualine_a = {
      {'tabs',
       mode = 2,
       max_length = function() return vim.o.columns end,
       show_modified_status = false,
       fmt = function(name, context) return tab_name(context.tabId) end
      }
    },
    lualine_z = {function() return 'CWD: ' .. vim.fn.getcwd() end},
  },
  extensions = {'fugitive'},
})

-- Hide the statusline in nerdtree by setting it to an empty Normal highlight
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'nerdtree',
  callback = function() vim.wo.statusline = '%#Normal#' end,
})

--------------------------------------------------------------------------------
-- DiffTool
--------------------------------------------------------------------------------
vim.cmd("packadd nvim.difftool")

local group = vim.api.nvim_create_augroup("DiffToolQfColors", {clear=true})
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = group,
  pattern = "quickfix",
  callback = function(ev)
    local qf = vim.fn.getqflist({ title = 0 })
    if qf.title ~= "DiffTool" then
      return
    end

    -- vim.schedule ensures this runs after nvim.difftool's own BufWinEnter
    vim.schedule(function()
      vim.api.nvim_set_hl(0, "MyDiffAdd",    {fg="#28e90f", bold=true})
      vim.api.nvim_set_hl(0, "MyDiffDelete", {fg="#ff0000", bold=true})
      vim.api.nvim_set_hl(0, "MyDiffText",    {fg="#fabd2f", bold=true})

      vim.api.nvim_buf_clear_namespace(ev.buf, vim.api.nvim_create_namespace("nvim.difftool.hl"), 0, -1)
      local ns = vim.api.nvim_create_namespace("my_difftool_override")
      vim.api.nvim_buf_clear_namespace(ev.buf, ns, 0, -1)

      local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
      for i, line in ipairs(lines) do
        local status = line:match("^(%S)")
        local hl =
          (status == "A" and "MyDiffAdd")
          or (status == "D" and "MyDiffDelete")
          or (status == "M" and "MyDiffText")
          or (status == "R" and "MyDiffText")

        if hl then
          vim.hl.range(ev.buf, ns, hl, { i - 1, 0 }, { i - 1, 1 })
        end
      end
    end)
  end,
})

--------------------------------------------------------------------------------
-- User Interface
--------------------------------------------------------------------------------
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
  local output = vim.api.nvim_exec2(command, {output=true}).output
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
