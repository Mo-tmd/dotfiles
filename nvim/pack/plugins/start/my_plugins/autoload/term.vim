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

    if GoToBuffer(bufname) != 'ok'
        execute 'terminal'
        execute 'file ' . bufname
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

" * Go to a buffer and return 'ok' if it exists.
" * Return 'error' if it doesn't exist.
" * If the buffer exists and is neither loaded nor listed, kill the
"   buffer and return 'error'.
"   Don't know why this happens sometimes. Noticed this for terminals
"   where it would go to the buffer, but it's not a terminal.
function! GoToBuffer(bufname)
    let bufnr = bufnr('^' . a:bufname . '$')
    if bufnr > 0
        if bufloaded(bufnr) || buflisted(bufnr)
            execute 'buffer! ' . bufnr
            return 'ok'
        else
            execute 'bwipeout ' . bufnr
            return 'error'
        endif
    else
        return 'error'
    endif
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
    " The function s:maybe_entered_terminal_buffer relies on cursor position (line
    " specifically). When triggered by BufEnter, line('.') always
    " returns 1. This is probably because cursor hasn't been drawn yet or
    " similar. So add a delay to solve.
    " Update: this seems to also solve the issue where entering a terminal
    " buffer through :Buffers doesn't enter terminal mode for some reason.
    autocmd WinEnter,BufEnter * call timer_start(10, function('s:maybe_entered_terminal_buffer'))
    autocmd TermOpen * startinsert
augroup END

function! s:maybe_entered_terminal_buffer(...)
    if &buftype == 'terminal'
        let first_time = !exists('b:not_first_time')
        if (first_time)
            startinsert
            let b:not_first_time = 'true'
        elseif exists('b:left_in_terminal_mode')
            unlet b:left_in_terminal_mode
            startinsert
        elseif (line('.') >= s:get_last_non_empty_line())
            startinsert
        endif
    elseif &filetype != 'TelescopePrompt' && &filetype != 'alpha'
        stopinsert
    endif
endfunction

function! s:get_last_non_empty_line()
    " Start from the last line in the buffer
    let last_line = line('$')

    " Loop backwards until a non-empty line is found
    while last_line > 0
        if getline(last_line) != ''
            return last_line
        endif
        let last_line -= 1
    endwhile

    " If no non-empty line is found, return 0
    return 0
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
