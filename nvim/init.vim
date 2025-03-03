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

    " telescope
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
    Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stuff that needs to be in the beginning
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ','

source $Dotfiles/nvim/vimscript/util.vim
source $Dotfiles/nvim/vimscript/terminals.vim
source $Dotfiles/nvim/vimscript/alternate_buffer.vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" init.lua
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set runtimepath+=$Dotfiles/nvim
lua require('init')

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
call Tmap('<C-j>', ':call TerminalMoveWindow("j")<CR>')
call Tmap('<C-k>', ':call TerminalMoveWindow("k")<CR>')
call Tmap('<C-h>', ':call TerminalMoveWindow("h")<CR>')
call Tmap('<C-l>', ':call TerminalMoveWindow("l")<CR>')
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
call Tmap('ii', '')
nnoremap <silent> <CR> :noh<CR><CR>

nnoremap <leader>q :q<CR>
tnoremap <leader>q <C-\><C-n>:let b:LeftInTerminalMode=1<CR>:q<CR>

cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

nnoremap <leader>le `.

nnoremap <leader>dt :lua toggle_diagnostics()<CR>

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
call Tmap('<leader>kb', ':call KillBuffer()<CR>')
function! KillBuffer()
    let l:BufferToKill = bufnr()
    let l:AlternateBuffer = GetAlternateBuffer()
    if l:AlternateBuffer != -1
        execute 'buffer! ' . l:AlternateBuffer
    else
        execute 'enew'
    endif
    if bufexists(l:BufferToKill)
        execute 'bwipeout! ' . l:BufferToKill
    else
        : " Probably buhidden=wipe
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
    if exists('g:is_merging')
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
    if (has('nvim'))
        "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
        let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    endif
    "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
    "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
    " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
    if (has('termguicolors'))
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
    if &modifiable && &buftype !=# 'terminal' && &filetype !=# 'TelescopeResults'
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
nnoremap <leader>b :Buffers<CR>
call Tmap('<leader>b', ':let b:LeftInTerminalMode=1<CR>:Buffers<CR>')

nnoremap <silent> <leader>af
  \ :call FzfFindFiles(
  \   {'search_dirs': ['~', getcwd()],
  \    'rg_exclude_paths': [],
  \    'full': 1
  \   }
  \  )<CR>
call Tmap('<leader>af', ':let b:LeftInTerminalMode=1<CR><leader>af', 1)

let g:MyRgExcludePaths = ['.git/', '**/.m2/repository/', '**/python*/site-packages/', '.cache/', '**/mason/packages/', '**/.config/google-chrome/', '**/.config/Code/', '**/.config/nvim/', '.eclipse/']
nnoremap <silent> <leader>f
  \ :call FzfFindFiles(
  \   {'search_dirs': ['~', getcwd()],
  \    'rg_exclude_paths': g:MyRgExcludePaths,
  \    'full': 0
  \   }
  \  )<CR>
call Tmap('<leader>f', ':let b:LeftInTerminalMode=1<CR><leader>f', 1)

let s:MyRgCmd = 'rg --no-config --hidden --follow --no-messages'
function! FzfFindFiles(Args)
    let l:SearchDirectories = get(a:Args, 'search_dirs',      [])
    let l:RgExcludePaths    = get(a:Args, 'rg_exclude_paths', [])
    let l:Full              = get(a:Args, 'full')
    let l:SearchDirectories = s:ProcessSearchDirectories(l:SearchDirectories)
    let l:RgExcludePaths = s:ProcessRgExcludePaths(l:RgExcludePaths)
    let l:RgCmd = (l:Full ? s:MyRgCmd.' --no-ignore' : s:MyRgCmd)
    let l:RgCmd = printf('%s %s --files -- %s', l:RgCmd, l:RgExcludePaths, l:SearchDirectories)
    call fzf#run(fzf#wrap(fzf#vim#with_preview({'source': l:RgCmd})))
endfunction

" e.g. s:ProcessSearchDirectories(['~', '/home/<User>', '/path with spaces', '~/dotfiles']) returns a string:
" `'/home/<User>' '/path with spaces'`
function! s:ProcessSearchDirectories(Directories)
    let l:Directories = copy(a:Directories)
    call map(l:Directories, 'expand(v:val)') " Expand paths.
    " Remove duplicates and directories whose parents are already in search_dirs
    call map(l:Directories, 'substitute(v:val, "/$", "", "")') " Remove trailing slashes.
    call sort(l:Directories)
    if len(l:Directories) > 1
        for l:PossibleChildIndex in reverse(range(1, len(l:Directories)-1))
            for l:PossibleParentIndex in range(0, l:PossibleChildIndex-1)
                if l:Directories[l:PossibleChildIndex] =~# '^' . l:Directories[l:PossibleParentIndex] . '\(/\|$\)'
                    call remove(l:Directories, l:PossibleChildIndex)
                    break
                endif
            endfor
        endfor
    endif
    call map(l:Directories, 'fzf#shellescape(v:val)')
    return join(l:Directories, ' ') " Convert the list to a string with space separated directories
endfunction

" e.g. s:ProcessRgExcludePaths(['some_dir/', '**/some dir/*.beam']) returns a string:
" `-g '!some_dir' -g '!**/some folder/*.beam'`
function! s:ProcessRgExcludePaths(Paths)
    let l:Paths = copy(a:Paths)
    call map(l:Paths, '"!" . v:val') " Prefix with `!`
    call map(l:Paths, 'fzf#shellescape(v:val)')
    call map(l:Paths, '"-g " . v:val') " Prefix with `-g `
    return join(l:Paths, ' ') " Convert the list to a string with space separated arguments
endfunction

" e.g. :Mrg ~/path\ with\ spaces some search query
command! -bang -nargs=+ -complete=file Mrg call MyRipGrep(<q-args>, <bang>0)
function! MyRipGrep(PathAndQuery, Full)
    for i in range(0, len(a:PathAndQuery)-1)
        if a:PathAndQuery[i] == ' ' && a:PathAndQuery[i-1] != '\'
            let l:Path = strpart(a:PathAndQuery, 0, i)
            let l:Query = strpart(a:PathAndQuery, i+1)
            break
        elseif i == len(a:PathAndQuery)-1
            let l:Path = a:PathAndQuery
            let l:Query = ''
        endif
    endfor
    let l:Path = substitute(l:Path, '\\ ', ' ', 'g') " Unescape spaces.
    let l:Path = expand(l:Path)
    let l:Cmd = printf('%s %s --column --line-number --no-heading --with-filename --color=always --smart-case -- %s %s || true',
      \                s:MyRgCmd,
      \                (a:Full ? '--no-ignore --binary' : '-g '.fzf#shellescape('!.git/')),
      \                fzf#shellescape(l:Query),
      \                fzf#shellescape(l:Path)
      \               )
    call fzf#vim#grep(l:Cmd, fzf#vim#with_preview(), 0)
endfunction

command! -bang -nargs=* Gg
  \ call fzf#vim#grep(
  \   (<q-args> == '' ? 'git grep --line-number -v ^$' : 'git grep --line-number -- '.fzf#shellescape(<q-args>)),
  \   fzf#vim#with_preview({'dir': systemlist('git -C ' . shellescape(expand('%:p:h')) . ' rev-parse --show-toplevel')[0]}),
  \   <bang>0
  \ )

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
    call call('fugitive#Diffsplit', a:000)
    set splitright
    wincmd l
endfunction

nnoremap <leader>cd :call CloseDiff()<CR>
function! CloseDiff()
    let l:Windows = range(1, winnr('$')) " Iterate through all windows in the current tab.
    for l:Window in l:Windows
        let l:Buffer = winbufnr(l:Window)
        if bufname(l:Buffer) =~ '^fugitive:///.*\.git.*//\S\+'
            let l:AllBufferWindows = win_findbuf(l:Buffer)
            if len(l:AllBufferWindows) == 1
                " The buffer doesn't exist in other windows, just wipeout.
                execute 'bwipeout ' . l:Buffer
            elseif len(l:AllBufferWindows) > 1
                " The buffer exists in other windows. Just close the window.
                call win_execute(win_getid(l:Window), 'close')
            endif
            break
        endif
    endfor
endfunction

command! -nargs=* Gs call GitShow(<f-args>)
function! GitShow(...)
    let l:Commit = len(a:000) > 0 ? a:000[0] : 'HEAD'
    let l:File = len(a:000) > 1 ? a:000[1] : ''
    exec printf('G difftool -y %s~1 %s %s', l:Commit, l:Commit, l:File)
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
" Man pages
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd filetype man setlocal number relativenumber | setlocal nowrap

command! -nargs=* -complete=customlist,v:lua.require'man'.man_complete Mn call MyMan(<q-args>)
function! MyMan(Args)
    try
        call TryMyMan(a:Args)
    catch
        echohl ErrorMsg
        echom v:exception
        echohl None
    finally
        if (&filetype == 'man')
            exec 'nnoremap <silent> <buffer> q :call GoToAlternateBuffer()<CR>'
            if bufname() !~ '^\d\+ man'
                " There's a bug in Man when invoked as a MANPAGER. It would crash if there's
                " already an existing buffer with the same name as the new man page.
                " See https://github.com/neovim/neovim/issues/30132
                " Workaround: prefix buffer name with buffer number to make it unique.
                execute 'file ' . bufnr() . ' ' . bufname()
                setlocal bufhidden=
            endif
        endif
    endtry
endfunction

function! TryMyMan(Args)
    let l:FirstManWindow = GetFirstManWindow()
    if (l:FirstManWindow == 0)
        exec 'Man ' . a:Args
        let l:ManBuffer = bufnr('%')
        q
        exec 'buffer! ' . l:ManBuffer
    else
        if (&filetype != 'man') | exec 'buffer! ' . winbufnr(l:FirstManWindow) | endif
        exec 'Man ' . a:Args
        for l:Buffer in range(1, bufnr('$'))
            if l:Buffer != bufnr() && bufexists(l:Buffer) && bufname(l:Buffer) =~ '^\d\+ ' . bufname()
                execute 'bwipeout! %'
                execute 'buffer! ' . l:Buffer
                return
            endif
        endfor
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
" Stuff that needs to be at the end
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
