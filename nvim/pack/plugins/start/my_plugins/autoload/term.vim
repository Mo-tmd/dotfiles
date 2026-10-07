""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" setup
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#setup()
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Start/go_to a terminal. Usage examples:
"     * :T Terminal name
"     * :call term#new('Terminal name', 'Start action', 'Another start action')
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! -nargs=? T call term#new(<q-args>)
command! -nargs=? TH call term#new(<q-args>, 'cd '.expand('%:h'))
function! term#new(...)
    if len(a:000) > 0
        let bufname = (len(a:000[0]) > 0 ? term#bufname(a:000[0]) : s:make_bufname())
        let start_actions = a:000[1:]
    else
        let bufname = s:make_bufname()
        let start_actions = []
    endif

    let bufnr = bufnr('^' . bufname . '$')
    if bufnr > 0
        execute 'buffer! ' . bufnr
    else
        execute 'terminal'
        call RenameBuffer(bufname)
        for mapping in s:my_terminal_mappings | execute mapping | endfor
        for start_action in start_actions
            call feedkeys(start_action . "\<CR>", 'n')
        endfor
    endif
endfunction

function! s:make_bufname()
    if !exists('s:terminal_number') | let s:terminal_number = 0 | endif
    let s:terminal_number += 1
    return term#bufname(string(s:terminal_number))
endfunction

function! term#bufname(terminal_name)
    return 'Term: ' . a:terminal_name
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Creates a terminal mode mapping only for terminals started through term#new(...)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#map(lhs, rhs, remap=0)
    if !exists('s:my_terminal_mappings') | let s:my_terminal_mappings = [] | endif
    let mapping = printf('%s <silent> <buffer> %s <C-\><C-n>%s',
                          \(a:remap ? 'tmap' : 'tnoremap'),
                          \a:lhs,
                          \a:rhs
                         \)
    let s:my_terminal_mappings += [mapping]
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Creates a mapping in both normal and terminal modes to start/go_to a terminal.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#define(lhs, terminal_name, ...)
    let start_actions = a:000
    let args = [a:terminal_name] + start_actions
    let quoted_args = map(args, 'printf("\"%s\"", v:val)')
    let args_string = join(quoted_args, ',')
    exec printf('nnoremap <silent> %s :call call("term#new", [%s])<CR>', a:lhs, args_string)
    call term#map(a:lhs, printf(':execute (bufname() == "%s" ? "startinsert" : ''let b:left_in_terminal_mode=1 \| call call("term#new", [%s])'')<CR>', term#bufname(a:terminal_name), args_string))
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Automatically enter insert mode when entering a terminal window/buffer
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup MaybeEnteredTerminalBuffer
    autocmd!
    autocmd WinEnter,BufEnter * call s:maybe_entered_terminal_buffer()
    autocmd TermOpen * startinsert
augroup END

function! s:maybe_entered_terminal_buffer()
    if &buftype == 'terminal' && exists('b:left_in_terminal_mode')
            unlet b:left_in_terminal_mode
            startinsert
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" A hacky port of https://vimhelp.org/terminal.txt.html#term_sendkeys%28%29
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#send_keys(target_buffer, keys)
    if !bufexists(a:target_buffer)
        throw 'target_buffer doesn''t exist'
    endif

    execute 'vsplit'
    execute 'buffer! ' . a:target_buffer
    startinsert
    call feedkeys(a:keys, 'n')
    if getbufvar(a:target_buffer, '&buftype') == 'terminal'
        let go_to_normal_mode = "\<C-\>\<C-n>"
    else
        let go_to_normal_mode = "\<Esc>"
    endif
    call feedkeys(go_to_normal_mode, 'n')
    call feedkeys(":q\<CR>", 'n')
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Move from terminal buffer window to another window. Example usage:
" call term#map('<C-j>', ':call term#move_to_window("j")<CR>')
" call term#map('<C-k>', ':call term#move_to_window("k")<CR>')
" call term#map('<C-h>', ':call term#move_to_window("h")<CR>')
" call term#map('<C-l>', ':call term#move_to_window("l")<CR>')
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#move_to_window(direction)
    let current_window = winnr()
    let target_window = winnr(a:direction)
    if (current_window == target_window)
        " There's no window in that direction. Do nothing
        " and go back to terminal mode.
        startinsert
    else
        let b:left_in_terminal_mode=1
        exec 'wincmd ' . a:direction
    endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#go_to_alternate_buffer()
    let b:left_in_terminal_mode=1
    " A bit ugly to depend on another plugin
    if alternate_buffer#go() == -1
        unlet b:left_in_terminal_mode
        startinsert
    endif
endfunction
