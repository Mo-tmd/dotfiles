"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-plug
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin()
    " FZF
    Plug 'junegunn/fzf', { 'do': { -> fzf#install()  }  }
    Plug 'junegunn/fzf.vim'

    " Gruvbox
    Plug 'morhetz/gruvbox'

    " Git
    Plug 'tpope/vim-fugitive'
    Plug 'rhysd/conflict-marker.vim'

    " LSP Support
    Plug 'neovim/nvim-lspconfig'                           " Required
    Plug 'williamboman/mason.nvim', {'do': ':MasonUpdate'} " Optional
    Plug 'williamboman/mason-lspconfig.nvim'               " Optional
    " Autocompletion
    Plug 'hrsh7th/nvim-cmp'         " Required
    Plug 'hrsh7th/cmp-nvim-lsp'     " Required
    Plug 'L3MON4D3/LuaSnip'         " Required
    Plug 'saadparwaiz1/cmp_luasnip' " Optional
    Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v2.x'}

    " nerdtree
    Plug 'preservim/nerdtree'

    " Lightline
    Plug 'itchyny/lightline.vim'

    " yanky
    Plug 'gbprod/yanky.nvim'
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stuff that needs to be in the beginning
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GetFullTerminalName(...)
    if len(a:000) > 0 && len(a:000[0]) > 0
        let l:TerminalName = a:000[0]
    else
        if exists('s:TerminalNumber')
            let s:TerminalNumber += 1
        else
            let s:TerminalNumber = 1
        endif
        let l:TerminalName = s:TerminalNumber
    endif
    return 'Term: ' . l:TerminalName
endfunction

let mapleader = ","

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Adds a terminal mode mapping to a list. These mappings will then later be
" applied only to "my" terminals. i.e., terminals created through Terminal()
function! Tnoremap(Lhs, Rhs)
    if !exists('s:MyTerminalBindings')
        let s:MyTerminalBindings = []
    endif
    let l:Binding = 'tnoremap <silent> <buffer> ' . a:Lhs . ' <C-\><C-n>' . a:Rhs
    let s:MyTerminalBindings += [l:Binding]
endfunction

" Creates a mapping in both normal and terminal modes to
" start/go_to a terminal.
function! CreateMapForStartingTerminal(Lhs, TerminalName, ...)
    let l:Args = [a:TerminalName] + a:000
    let l:QuotedArgs = map(l:Args, 'printf("\"%s\"", v:val)')
    let l:ArgsString = join(l:QuotedArgs, ',')
    exec printf('nnoremap <silent> %s :call call("Terminal", [%s])<CR>', a:Lhs, l:ArgsString)
    call Tnoremap(a:Lhs, printf(':execute (bufname("%") == "%s" ? "startinsert" : ''let b:LeftInTerminalMode=1 \| call call("Terminal", [%s])'')<CR>', GetFullTerminalName(a:TerminalName), l:ArgsString))
endfunction

set timeoutlen=500

nnoremap <A-Left> <C-o>
nnoremap 3D <C-o>
nnoremap <A-Right> <C-i>
nnoremap 3C <C-i>

nnoremap <leader>sp :vsplit<CR>

" Smart way to move between windows
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
call Tnoremap('<C-j>', ':call TerminalMoveWindow("j")<CR>')
call Tnoremap('<C-k>', ':call TerminalMoveWindow("k")<CR>')
call Tnoremap('<C-h>', ':call TerminalMoveWindow("h")<CR>')
call Tnoremap('<C-l>', ':call TerminalMoveWindow("l")<CR>')
function! TerminalMoveWindow(Direction)
    let l:CurrentWindow = winnr()
    let l:TargetWindow = winnr(a:Direction)
    if (l:CurrentWindow == l:TargetWindow)
        " There's no window in that direction. Do nothing
        " and go back to terminal mode.
        startinsert
    else
        let b:LeftInTerminalMode=1
        exec 'wincmd ' . a:Direction
    endif
endfunction
" netrw overrides my mappings. So override them again here :D
autocmd filetype netrw nnoremap <buffer> <C-h> <C-W>h
autocmd filetype netrw nnoremap <buffer> <C-l> <C-W>l

nnoremap <leader>iv :e ~/dotfiles/nvim/init.vim<CR>
nnoremap <leader>il :e ~/dotfiles/nvim/lua/init.lua<CR>

inoremap ii <Esc>
call Tnoremap('ii', '<C-\><C-n>')
nnoremap <silent> <CR> :noh<CR><CR>

nnoremap <leader>q :q<CR>
tnoremap <leader>q <C-\><C-n>:let b:LeftInTerminalMode=1<CR>:q<CR>

cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

nnoremap <leader>le `.

nnoremap <leader>dt :lua toggle_diagnostics()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lua Scripts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:OldRuntimePath = &runtimepath
set runtimepath+=$Dotfiles/nvim
lua require('init')
if (s:OldRuntimePath != &runtimepath)
    set runtimepath-=$Dotfiles/nvim
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set number relativenumber

set path+=/home/user/dotfiles/scripts

set scrollback=100000

" Reload File
nnoremap <leader>rf :call ReloadFile()<CR>
function! ReloadFile()
    let l:FilePath = expand('%:p')
    call KillBuffer()
    execute 'edit ' . l:FilePath
endfunction

" Kill buffer
nnoremap <leader>kb :call KillBuffer()<CR>
call Tnoremap('<leader>kb', ':call KillBuffer()<CR>')
function! KillBuffer()
    let l:BufferNumber = bufnr('%')
    call GoToPreviousBuffer()
    if bufexists(l:BufferNumber)
        execute 'bwipeout! ' . l:BufferNumber
    else
        : " Probably buhidden=wipe
    endif
    " Call GoToPreviousBuffer() twice to get C-^ to work.
    call GoToPreviousBuffer()
    call GoToPreviousBuffer()
endfunction

" TODO: use window specific buffer history and not fzf history. Either do that
" manually, or look for some plugin.
function! GoToPreviousBuffer()
    let l:PreviousBuffer = GetPreviousBuffer()
    if bufexists(l:PreviousBuffer)
        execute 'buffer ' . l:PreviousBuffer
    endif
endfunction
function! GetPreviousBuffer()
    let l:AlternateBuffer = bufnr('#')
    let l:Buffers = fzf#vim#_buflisted_sorted()
    if bufexists(l:AlternateBuffer)
        return l:AlternateBuffer
    elseif len(l:Buffers) > 1
        " No alternate buffer. Use last buffer from fzf instead.
        return l:Buffers[1]
    else
        return -1
    endif
endfunction

nnoremap <leader>sc :call ScratchBuffer()<CR>
function! ScratchBuffer()
    let l:BufferName = 'Scratch Buffer'
    if GoToBuffer(l:BufferName) != 'ok'
        enew
        execute 'file ' . l:BufferName
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal nobuflisted
        setlocal noswapfile
        setlocal nolist
        setlocal nowrap
    endif
endfunction

command! -nargs=1 RenameBuffer call RenameBuffer(<q-args>)
function! RenameBuffer(NewName)
    let l:StartBuffer = bufnr('%')
    let l:AlternateBuffer = bufnr('#')
    exec 'file ' . a:NewName
    if bufexists(l:AlternateBuffer) && l:StartBuffer != l:AlternateBuffer
        " Renaming the buffer messes up <C-6> history.
        " Switch to PreviousBuffer and then switch back
        " to fix it.
        exec 'buffer ' . l:AlternateBuffer
        exec 'buffer#'
    endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" User Interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set scrolloff=10
set splitbelow
set splitright

" Disable mouse visual mode
set mouse=

command! Ws :w | source %

set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Status Line
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set laststatus=2

set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
set noshowmode

" Copied from https://vi.stackexchange.com/questions/22398/disable-lightline-on-nerdtree
augroup filetype_nerdtree
    au!
    au FileType nerdtree call s:disable_lightline_on_nerdtree()
    au WinEnter,BufWinEnter,TabEnter * call s:disable_lightline_on_nerdtree()
augroup END

fu s:disable_lightline_on_nerdtree() abort
    let nerdtree_winnr = index(map(range(1, winnr('$')), {_,v -> getbufvar(winbufnr(v), '&ft')}), 'nerdtree') + 1
    call timer_start(0, {-> nerdtree_winnr && setwinvar(nerdtree_winnr, '&stl', '%#Normal#')})
endfu

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Lightline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:lightline = {
      \ 'colorscheme': 'gruvbox',
      \ 'active': {
      \   'left': [ ['mode'],
      \             ['readonly', 'filename', 'modified'] ],
      \   'right': [ [ 'lineinfo' ], ['percent'] ]
      \ },
      \ 'inactive': {
      \   'left': [ ['mode'],
      \             ['readonly', 'filename', 'modified'] ],
      \   'right': [ [ 'lineinfo' ], ['percent'] ]
      \ },
      \ 'tabline': {
         \ 'left': [ [ 'tabs' ] ],
         \ 'right': [ [ 'cwd' ] ]
      \ },
      \ 'component': {
      \   'cwd': 'CWD: %{getcwd()}',
      \   'readonly': '%{&filetype=="help"?"":&readonly?"🔒":""}',
      \   'modified': '%{&filetype=="help"||&buftype=="terminal"?"":&modified?"+":&modifiable?"":"-"}',
      \   'fugitive': '%{exists("*FugitiveHead")?FugitiveHead():""}'
      \ },
      \ 'component_visible_condition': {
      \   'readonly': '(&filetype!="help"&& &readonly)',
      \   'modified': '(&filetype!="help"&&(&modified||!&modifiable))',
      \   'fugitive': '(exists("*FugitiveHead") && ""!=FugitiveHead())',
      \ },
      \ 'separator': { 'left': ' ', 'right': ' ' },
      \ 'subseparator': { 'left': ' ', 'right': ' ' }
      \ }

let g:lightline.tab = {
		    \ 'active': [ 'tabnum',  'tabname', 'modified' ],
		    \ 'inactive': [ 'tabnum',  'tabname', 'modified' ] }

let g:lightline.tab_component_function = {
            \  'tabname': 'TabName',
            \ }

function! TabName(n)
    if exists("g:is_merging")
        if a:n == 1
            return 'MERGED'
        elseif a:n == 2
            return 'BASE LOCAL'
        elseif a:n == 3
            return 'BASE REMOTE'
        elseif a:n == 4
            return 'LOCAL REMOTE'
        elseif a:n == 5
            return 'LOCAL BASE REMOTE'
        elseif a:n == 6
            return 'LOCAL MERGED'
        elseif a:n == 7
            return 'REMOTE MERGED'
        elseif a:n == 8
            return 'LOCAL MERGED REMOTE'
        else
            return 'error'
        endif
    else
        return lightline#tab#filename(a:n)
    endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Ignore case when searching
set ignorecase

" Use spaces instead of tabs
set expandtab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4
inoremap <Tab> <Space><Space><Space><Space>

" Avoid removing indentation when exiting insert mode after adding a line break.
" Copied from https://stackoverflow.com/a/7413117
inoremap <CR> <CR>x<BS>
nnoremap o ox<BS>
nnoremap O Ox<BS>

" Use system clipboard for yanking, deleting etc. Let's see how this works out.
set clipboard=unnamedplus

set nowrap
set smartindent

autocmd BufNewFile,BufRead *shell/variables,*shell/aliases set filetype=bash

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
"if (empty($TMUX))
    if (has("nvim"))
        "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
        let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    endif
    "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
    "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
    " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
    if (has("termguicolors"))
        set termguicolors
    endif
"endif
"let g:gruvbox_italic=1 TODO: doesn't work in TMUX

colorscheme gruvbox

hi DiffAdd      guifg=#5faf5f guibg=#262626
hi DiffChange   guifg=#767676 guibg=#262626
hi DiffDelete   guifg=#870000 guibg=#870087
hi DiffText     guifg=#ffaf00 guibg=#262626

" Highlight trailing spaces.
augroup TrailingSpaces
    autocmd!
    autocmd FileType,BufEnter,WinEnter * call ToggleTrailingSpaces()
    autocmd TermOpen,TermEnter * call ClearTrailingSpaces()

    autocmd InsertEnter * call ClearTrailingSpaces()
    autocmd InsertLeave * call ToggleTrailingSpaces()
augroup END

function! ToggleTrailingSpaces()
    if &modifiable && &buftype !=# 'terminal'
        call HighlightTrailingSpaces()
    else
        call ClearTrailingSpaces()
    endif
endfunction

function! HighlightTrailingSpaces()
    highlight TrailingSpaces ctermbg=red guibg=Red
    match TrailingSpaces /\s\+$/
endfunction

function! ClearTrailingSpaces()
    call clearmatches()
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fzf
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>af :Files<CR>
nnoremap <leader>df :Files ~/dotfiles<CR>
nnoremap <leader>b :Buffers<CR>
tnoremap <leader>b <C-\><C-n>:let b:LeftInTerminalMode=1<CR>:Buffers<CR>

" Below is copied from Oskar, I have no idea what it does for now
command! -nargs=* -bang FileContents call FileContentsFunc(<q-args>, <bang>0)
function! FileContentsFunc(query, fullscreen)
    let command_fmt = 'rg --column --line-number --no-heading --color=always -- %s || true'
    let initial_command = printf(command_fmt, shellescape(a:query))
    let reload_command = printf(command_fmt, '{q}')
    let spec = {'options': ['--disabled', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
    let spec = fzf#vim#with_preview(spec, 'right', 'ctrl-/')
    call fzf#vim#grep(initial_command, 1, spec, a:fullscreen)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Nerd Tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let NERDTreeShowHidden=1

nnoremap <leader>nt :NERDTreeToggle<CR>
nnoremap <leader>nc :NERDTreeFind<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-fugitive
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" The command and function wrappers for diffsplit are ugly, but I found no better
" way
exe 'command! -bar -bang -nargs=* -complete=customlist,fugitive#EditComplete Gd exe MyDiffsplit(0, <bang>0, "vertical <mods>", <q-args>)'
function! MyDiffsplit(...) abort
    set nosplitright
    call call("fugitive#Diffsplit", a:000)
    set splitright
    wincmd l
endfunction

nnoremap <leader>cd :call CloseDiff()<CR>
function! CloseDiff()
    let l:Buffers = tabpagebuflist()
    call sort(l:Buffers)
    call reverse(l:Buffers)

    for l:Buffer in l:Buffers
        let l:BufferName = bufname(l:Buffer)
        if l:BufferName =~ '^fugitive:///.*\.git.*//\S\+'
            execute 'bwipeout ' . l:Buffer
            break
        endif
    endfor
endfunction

command! -nargs=* Gs call GitShow(<f-args>)
function! GitShow(...)
    let l:Commit = len(a:000) > 0 ? a:000[0] : "HEAD"
    let l:File = len(a:000) > 1 ? a:000[1] : ""
    exec printf("G difftool -y %s~1 %s %s", l:Commit, l:Commit, l:File)
endfunction

" TODO this doesn't handle renames.
command! Grb call GitRecursiveBlame()
function! GitRecursiveBlame()
    let l:ReblameMapping = execute('nmap -')
    let l:FugitiveScript = matchstr(l:ReblameMapping, '<SNR>\d\+_')
    let [l:Commit, l:Path, l:Lnum] = call(l:FugitiveScript . 'BlameCommitFileLnum', [])
    call GitShow(expand('<cword>'), l:Path)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" YankRing
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:yankring_history_dir = "~/dump"
nnoremap <silent> <leader>p :YRShow<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Terminals
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call Tnoremap('<C-^>', ':call TerminalGoToAlternateBuffer()<CR>')
function! TerminalGoToAlternateBuffer()
    if bufexists(bufnr('#'))
        let b:LeftInTerminalMode=1
        execute 'buffer#'
    else
        echohl ErrorMsg
        echo "E23: No alternate file"
        echohl NONE
        startinsert
    endif
endfunction

call CreateMapForStartingTerminal('<leader>td', 'Dotfiles', 'cd ~/dotfiles')

command! -nargs=? Term call Terminal(<q-args>)
function! Terminal(...)
    if len(a:000) > 0 && len(a:000[0]) > 0
        let l:TerminalName = GetFullTerminalName(a:000[0])
        let l:StartActions = a:000[1:]
    else
        let l:TerminalName = GetFullTerminalName()
        let l:StartActions = []
    endif

    if GoToBuffer(l:TerminalName) != 'ok'
        execute 'terminal'
        call RenameBuffer(l:TerminalName)
        call SetMyTermBindings()
        for l:StartAction in l:StartActions
            call feedkeys(l:StartAction . "\<CR>", 'n')
        endfor
    endif
endfunction

" * Go to a buffer and return 'ok' if it exists.
" * Return 'error' if it doesn't exist.
" * If the buffer exists and is neither loaded nor listed, kill the
"   buffer and return 'error'.
"   Don't know why this happens sometimes. Noticed this for terminals
"   where it would go to the buffer, but it's not a terminal.
function! GoToBuffer(BufferName)
    let l:BufferNumber = bufnr('^' . a:BufferName . '$')
    if l:BufferNumber > 0
        if bufloaded(l:BufferNumber) || buflisted(l:BufferNumber)
            execute 'buffer ' . l:BufferNumber
            return 'ok'
        else
            execute 'bwipeout ' . l:BufferNumber
            return 'error'
        endif
    else
        return 'error'
    endif
endfunction

function! SetMyTermBindings()
    for l:KeyBinding in s:MyTerminalBindings
        execute l:KeyBinding
    endfor
endfunction

function! TermSendKeys(TargetBuffer, Keys)
    if !bufexists(a:TargetBuffer)
        throw "TargetBuffer doesn't exist"
    endif

    execute 'vsplit'
    execute 'buffer ' . a:TargetBuffer
    startinsert
    call feedkeys(a:Keys, 'n')
    if getbufvar(a:TargetBuffer, "&buftype") == "terminal"
        let l:GoToNormalMode = "\<C-\>\<C-n>"
    else
        let l:GoToNormalMode = "\<Esc>"
    endif
    call feedkeys(l:GoToNormalMode, 'n')
    call feedkeys(":q\<CR>", 'n')
endfunction

augroup TermEnterOrLeave
    autocmd!
    " The function ToggleTermEnterOrLeave relies on cursor position (line
    " specifically). When triggered by BufEnter, line('.') always
    " returns 1. This is probably becuase cursor hasn't been drawn yet or
    " similar. So add a delay to solve.
    " Update: this seems to also solve the issue where entering a terminal
    " buffer through :Buffers doesn't enter terminal mode for some reason.
    autocmd WinEnter,BufEnter * call timer_start(10, 'ToggleTermEnterOrLeave')
    autocmd TermOpen * startinsert
augroup END

function! ToggleTermEnterOrLeave(...)
    if &buftype == "terminal"
        let l:FirstTime = !exists("b:NotFirstTime")
        if (l:FirstTime)
            startinsert
            let b:NotFirstTime = "true"
        elseif exists('b:LeftInTerminalMode')
            unlet b:LeftInTerminalMode
            startinsert
        elseif (line('.') >= GetLastNonEmptyLine())
            startinsert
        endif
    else
        stopinsert
    endif
endfunction

function! GetLastNonEmptyLine()
    " Start from the last line in the buffer
    let l:LastLine = line('$')

    " Loop backwards until a non-empty line is found
    while l:LastLine > 0
        if getline(l:LastLine) != ''
            return l:LastLine
        endif
        let l:LastLine -= 1
    endwhile

    " If no non-empty line is found, return 0
    return 0
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Man pages
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd filetype man setlocal number relativenumber | setlocal nowrap

command! -nargs=* -complete=customlist,v:lua.require'man'.man_complete Mn call MyMan(<q-args>)
function! MyMan(Args)
    let l:StartBuffer = bufnr('%')
    let l:StartAlternateBuffer = bufnr('#')
    try
        call TryMyMan(a:Args)
    catch
        if bufexists(l:StartAlternateBuffer)
            exec 'buffer ' . l:StartAlternateBuffer
        endif
        exec 'buffer ' . l:StartBuffer
        echohl ErrorMsg
        echom v:exception
        echohl None
    finally
        if (&filetype == 'man')
            exec 'nnoremap <silent> <buffer> q :call GoToPreviousBuffer()<CR>'
            if bufname() !~ '^\d\+ man'
                " There's a bug in Man when invoked as a MANPAGER. It would crash if there's
                " already an existing buffer with the same name as the new man page.
                " See https://github.com/neovim/neovim/issues/30132
                " Workaround: prefix buffer name with buffer number to make it unique.
                setlocal bufhidden=
                call RenameBuffer(bufnr() . ' ' . bufname())
            endif
        endif
    endtry
endfunction

function! TryMyMan(Args)
    let l:StartBuffer = bufnr('%')
    let l:FirstManWindow = GetFirstManWindow()
    if (l:FirstManWindow == 0)
        exec 'Man ' . a:Args
        let l:MyManBufNr = bufnr('%')
        q
        exec 'buffer ' . l:MyManBufNr
    else
        if (&filetype != 'man')
            exec 'buffer ' . winbufnr(l:FirstManWindow)
        endif
        exec 'Man ' . a:Args
        for l:Buffer in range(1, bufnr('$'))
            if l:Buffer != bufnr() && bufexists(l:Buffer) && bufname(l:Buffer) =~ '^\d\+ ' . bufname()
                let l:DuplicateManBuffer = bufnr()
                exec 'buffer ' . l:StartBuffer
                exec 'buffer ' . l:Buffer
                exec 'bwipeout! ' . l:DuplicateManBuffer
                return
            endif
        endfor
        exec 'buffer ' . l:StartBuffer
        exec 'buffer#'
    endif
endfunction

function! GetFirstManWindow()
    for l:i in range(1, winnr('$'))
        let l:Buffer = winbufnr(l:i)
        if (getbufvar(l:Buffer,'&filetype') == 'man')
            return l:i
        endif
    endfor
    return 0
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" conflict-marker
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:conflict_marker_highlight_group = ''

let g:conflict_marker_begin = '^<<<<<<< .*$'
let g:conflict_marker_end   = '^>>>>>>> .*$'
let g:conflict_marker_common_ancestors = '^||||||| .*$'

let g:conflict_marker_enable_mappings = 0
nnoremap <leader>co :ConflictMarkerOurselves<CR>
nnoremap <leader>ct :ConflictMarkerThemselves<CR>
nnoremap <leader>cb :ConflictMarkerBoth<CR>
nnoremap <leader>cn :ConflictMarkerNextHunk<CR>
nnoremap <leader>cp :ConflictMarkerPrevHunk<CR>

highlight ConflictMarkerBegin               guifg=#7A7979
highlight ConflictMarkerOurs                guifg=#5faf5f guibg=#262626

highlight ConflictMarkerCommonAncestors     guifg=#7A7979
highlight ConflictMarkerCommonAncestorsHunk guifg=#FF4848

highlight ConflictMarkerTheirs              guifg=#2991C1
highlight ConflictMarkerEnd                 guifg=#7A7979

highlight ConflictMarkerSeparator           guifg=#7A7979

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General TODOs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TODO buffers that get auto wiped (e.g. using bufhidden=wipe) can mess with
" <C-^> history. Perhaps add some autocmd if possible and manually fix alternate
" file history. Or perhaps better to make <C-^> use PreviousBuffer() instead.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stuff that needs to be at the end
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

