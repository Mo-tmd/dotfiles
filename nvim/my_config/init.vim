""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Stuff that needs to be in the beginning
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ','
call term#setup()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set timeoutlen=500

nnoremap <leader>sp :vsplit<CR>

" Smart way to move between windows
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
call term#map('<C-j>', ':call term#move_to_window("j")<CR>')
call term#map('<C-k>', ':call term#move_to_window("k")<CR>')
call term#map('<C-h>', ':call term#move_to_window("h")<CR>')
call term#map('<C-l>', ':call term#move_to_window("l")<CR>')
" netrw overrides my mappings. So override them again here :D
autocmd filetype netrw nnoremap <buffer> <C-h> <C-W>h
autocmd filetype netrw nnoremap <buffer> <C-l> <C-W>l

nnoremap <silent> <C-^> :call alternate_buffer#go()<CR>
call term#map('<C-^>', ':call term#go_to_alternate_buffer()<CR>')

nnoremap <silent> <leader>vp :e $Dotfiles/nvim/my_config/init.vim<CR>
nnoremap <silent> <leader>ip :e $Dotfiles/nvim/lua/my_config/init.lua<CR>

nnoremap <silent> <leader>yn :let @+ = expand('%:t') \| echo @+<CR>
nnoremap <silent> <leader>yp :let @+ = expand('%:p') \| echo @+<CR>

inoremap ii <Esc>
call term#map('ii', '')
nnoremap <silent> <CR> :noh<CR><CR>

nnoremap <leader>q :q<CR>
tnoremap <leader>q <C-\><C-n>:let b:left_in_terminal_mode=1<CR>:q<CR>

cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

nnoremap <leader>le `.

nnoremap gd <C-]>

nnoremap <silent> <leader>gt :tabnew<CR>
nnoremap <silent> <leader>to :tabonly<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set number relativenumber

set scrollback=1000000

set mouse= " Disable mouse visual mode

command! Ws :w | source %

set noswapfile

set scrolloff=10

set splitbelow
set splitright

" Reload File
nnoremap <leader>rf :call <SID>reload_file()<CR>
function! s:reload_file()
    let file_path = expand('%:p')
    call KillBuffer()
    execute 'edit ' . file_path
endfunction

" Kill buffer
nnoremap <leader>kb :call KillBuffer()<CR>
call term#map('<leader>kb', ':call KillBuffer()<CR>')
function! KillBuffer()
    let buffer_to_kill = bufnr()
    let alternate_buffer = alternate_buffer#get()
    if alternate_buffer != -1
        execute 'buffer! ' . alternate_buffer
    else
        execute 'enew'
    endif
    if bufexists(buffer_to_kill)
        execute 'bwipeout! ' . buffer_to_kill
    else
        : " Probably buhidden=wipe
    endif
endfunction

nnoremap <leader>sc :call <SID>scratch_buffer()<CR>
function! s:scratch_buffer()
    let bufname = 'Scratch Buffer'
    if GoToBuffer(bufname) != 'ok'
        enew
        execute 'file ' . bufname
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal nobuflisted
        setlocal noswapfile
        setlocal nolist
        setlocal nowrap
    endif
endfunction

" trigger `autoread` when files changes on disk. Inspired by https://stackoverflow.com/a/62936797
set autoread
autocmd FocusGained,BufEnter,WinEnter,CursorHold,CursorHoldI * call timer_start(1, { -> execute('if getcmdwintype() == "" | checktime | endif') })

au TermOpen * if bufname() !~# 'fzf' | setlocal number relativenumber | endif
call term#define('<leader>td', 'Dotfiles', 'cd ~/dotfiles')

function! PlugPostHooks()
    call plug#post_hooks({'dir': 'fzf',                        'do': { -> fzf#install() }},
                      \  {'dir': 'mason.nvim',                 'do': ':MasonUpdate'},
                      \  {'dir': 'telescope-fzf-native.nvim',  'do': 'make'}
                      \ )
endfunction

set diffopt+=context:999999

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

" Use system clipboard for yanking, deleting etc.
set clipboard=unnamedplus

set nowrap
set smartindent

autocmd BufNewFile,BufRead *shell/variables,*shell/aliases set filetype=bash

call spellcheck#setup()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Status Line
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set laststatus=2
set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
set noshowmode

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colors
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-better-whitespace
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:better_whitespace_enabled = 0
let g:strip_whitespace_on_save = 1
let g:strip_only_modified_lines = 1
let g:strip_whitespace_confirm = 0

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fzf
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>b :Telescope buffers<CR>
call term#map('<leader>b', ':let b:left_in_terminal_mode=1<CR>:Telescope buffers<CR>')

autocmd FileType fzf nnoremap <silent> <buffer> <Esc> :q<CR>
autocmd FileType fzf autocmd WinLeave <buffer> close

nnoremap <silent> <leader>af
  \ :call FzfFindFiles(
  \   {'search_dirs': ['~', getcwd()],
  \    'rg_exclude_paths': [],
  \    'full': 1
  \   }
  \  )<CR>
call term#map('<leader>af', ':let b:left_in_terminal_mode=1<CR><leader>af', 1)

let g:my_rg_exclude_paths = ['.git/', '**/.m2/repository/', '**/python*/site-packages/', '.cache/', '**/mason/packages/', '**/.config/google-chrome/', '**/.config/Code/', '**/.config/nvim/', '.eclipse/']
nnoremap <silent> <leader>f
  \ :call FzfFindFiles(
  \   {'search_dirs': ['~', getcwd()],
  \    'rg_exclude_paths': g:my_rg_exclude_paths,
  \    'full': 0
  \   }
  \  )<CR>
call term#map('<leader>f', ':let b:left_in_terminal_mode=1<CR><leader>f', 1)

let s:my_rg_cmd = 'rg --no-config --hidden --follow --no-messages'
function! FzfFindFiles(args)
    let search_directories = get(a:args, 'search_dirs',      [])
    let rg_exclude_paths    = get(a:args, 'rg_exclude_paths', [])
    let full              = get(a:args, 'full')
    let search_directories = s:process_search_directories(search_directories)
    let rg_exclude_paths = s:process_rg_exclude_paths(rg_exclude_paths)
    let rg_cmd = (full ? s:my_rg_cmd.' --no-ignore' : s:my_rg_cmd)
    let rg_cmd = printf('%s %s --files -- %s', rg_cmd, rg_exclude_paths, search_directories)
    call fzf#run(fzf#wrap(fzf#vim#with_preview({'source': rg_cmd})))
endfunction

" e.g. s:process_search_directories(['~', '/home/<User>', '/path with spaces', '~/dotfiles']) returns a string:
" `'/home/<User>' '/path with spaces'`
function! s:process_search_directories(directories)
    let directories = copy(a:directories)
    call map(directories, 'expand(v:val)') " Expand paths.
    " Remove duplicates and directories whose parents are already in search_dirs
    call map(directories, 'substitute(v:val, "/$", "", "")') " Remove trailing slashes.
    call sort(directories)
    if len(directories) > 1
        for possible_child_index in reverse(range(1, len(directories)-1))
            for possible_parent_index in range(0, possible_child_index-1)
                if directories[possible_child_index] =~# '^' . directories[possible_parent_index] . '\(/\|$\)'
                    call remove(directories, possible_child_index)
                    break
                endif
            endfor
        endfor
    endif
    call map(directories, 'fzf#shellescape(v:val)')
    return join(directories, ' ') " Convert the list to a string with space separated directories
endfunction

" e.g. s:process_rg_exclude_paths(['some_dir/', '**/some dir/*.beam']) returns a string:
" `-g '!some_dir' -g '!**/some folder/*.beam'`
function! s:process_rg_exclude_paths(paths)
    let paths = copy(a:paths)
    call map(paths, '"!" . v:val') " Prefix with `!`
    call map(paths, 'fzf#shellescape(v:val)')
    call map(paths, '"-g " . v:val') " Prefix with `-g `
    return join(paths, ' ') " Convert the list to a string with space separated arguments
endfunction

" e.g. :Mrg ~/path\ with\ spaces some search query
command! -bang -nargs=+ -complete=file Mrg call <SID>my_rip_grep(<q-args>, <bang>0)
function! s:my_rip_grep(path_and_query, full)
    for i in range(0, len(a:path_and_query)-1)
        if a:path_and_query[i] == ' ' && a:path_and_query[i-1] != '\'
            let path = strpart(a:path_and_query, 0, i)
            let query = strpart(a:path_and_query, i+1)
            break
        elseif i == len(a:path_and_query)-1
            let path = a:path_and_query
            let query = ''
        endif
    endfor
    let path = substitute(path, '\\ ', ' ', 'g') " Unescape spaces.
    let path = expand(path)
    let cmd = printf('%s %s --column --line-number --no-heading --with-filename --color=always --smart-case -- %s %s || true',
      \                s:my_rg_cmd,
      \                (a:full ? '--no-ignore --binary' : '-g '.fzf#shellescape('!.git/')),
      \                fzf#shellescape(query),
      \                fzf#shellescape(path)
      \               )
    call fzf#vim#grep(cmd, fzf#vim#with_preview(), 0)
endfunction

command! -bang -nargs=* Gg
  \ call fzf#vim#grep(
  \   (<q-args> == '' ? 'git grep --recurse-submodules --line-number -v ^$' : 'git grep --recurse-submodules --line-number -- '.fzf#shellescape(<q-args>)),
  \   fzf#vim#with_preview({'dir': systemlist('git -C ' . shellescape(expand('%:p:h')) . ' rev-parse --show-toplevel')[0]}),
  \   <bang>0
  \ )

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Nerd Tree
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let NERDTreeShowHidden=1
let g:NERDTreeWinSize = 40

nnoremap <leader>nt :NERDTreeToggle<CR>
nnoremap <leader>nc :NERDTreeFind<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-fugitive
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Disable fugitive's automatic diffoff.
autocmd BufWinEnter fugitive://* augroup fugitive_diff | autocmd! | augroup END

" The command and function wrappers for diffsplit are ugly, but I found no better
" way
exe 'command! -bar -bang -nargs=* -complete=customlist,fugitive#EditComplete Gd exe <SID>my_diffsplit(0, <bang>0, "vertical <mods>", <q-args>)'
function! s:my_diffsplit(...) abort
    set nosplitright
    call call('fugitive#Diffsplit', a:000)
    set splitright
    wincmd l
endfunction

command! -nargs=* Gs call <SID>git_show(<f-args>)
function! s:git_show(...)
    let commit = len(a:000) > 0 ? a:000[0] : 'HEAD'
    let file = len(a:000) > 1 ? a:000[1] : ''
    exec printf('G difftool -y %s~1 %s %s', commit, commit, file)
endfunction

" TODO this doesn't handle renames.
command! Grb call <SID>git_recursive_blame()
function! s:git_recursive_blame()
    let reblame_mapping = execute('nmap -')
    let fugitive_script = matchstr(reblame_mapping, '<SNR>\d\+_')
    let [commit, path, lnum] = call(fugitive_script . 'BlameCommitFileLnum', [])
    call <SID>git_show(expand('<cword>'), path)
endfunction

nnoremap <leader>gg :G grep -iF -- <C-r>=shellescape(expand('<cword>'))<CR><CR>
nnoremap <leader>GG :G grep -F -- <C-r>=shellescape(expand('<cword>'))<CR><CR>
xnoremap <silent> <leader>gg y:<C-u>G grep -iF -- <C-r>=shellescape(@")<CR><CR>
xnoremap <silent> <leader>GG y:<C-u>G grep -F -- <C-r>=shellescape(@")<CR><CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Man pages
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd filetype man setlocal number relativenumber | setlocal nowrap

command! -nargs=* -complete=customlist,v:lua.require'man'.man_complete Mn call <SID>my_man(<q-args>)
function! s:my_man(args)
    try
        call <SID>try_my_man(a:args)
    catch
        echohl ErrorMsg
        echom v:exception
        echohl None
    finally
        if (&filetype == 'man')
            exec 'nnoremap <silent> <buffer> q :call alternate_buffer#go()<CR>'
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

function! s:try_my_man(args)
    let first_man_window = <SID>get_first_man_window()
    if (first_man_window == 0)
        exec 'Man ' . a:args
        let man_buffer = bufnr()
        q
        exec 'buffer! ' . man_buffer
    else
        if (&filetype != 'man') | exec 'buffer! ' . winbufnr(first_man_window) | endif
        exec 'Man ' . a:args
        for bufnr in range(1, bufnr('$'))
            if bufnr != bufnr() && bufexists(bufnr) && bufname(bufnr) =~ '^\d\+ ' . bufname()
                execute 'bwipeout! %'
                execute 'buffer! ' . bufnr
                return
            endif
        endfor
    endif
endfunction

function! s:get_first_man_window()
    for i in range(1, winnr('$'))
        let bufnr = winbufnr(i)
        if (getbufvar(bufnr,'&filetype') == 'man')
            return i
        endif
    endfor
    return 0
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" conflict-marker
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
