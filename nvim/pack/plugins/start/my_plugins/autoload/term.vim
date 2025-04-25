"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" setup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#setup()
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Start/go_to a terminal. Usage examples:
"     * :T Terminal name
"     * :call term#new('Terminal name', 'Start action', 'Another start action')
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! -nargs=? T call term#new(<q-args>)
command! -nargs=? TH call term#new(<q-args>, 'cd '.expand('%:h'))
function! term#new(...)
    if len(a:000) > 0
        let l:TerminalName = (len(a:000[0]) > 0 ? s:get_full_terminal_name(a:000[0]) : s:make_terminal_name())
        let l:StartActions = a:000[1:]
    else
        let l:TerminalName = s:make_terminal_name()
        let l:StartActions = []
    endif

    if GoToBuffer(l:TerminalName) != 'ok'
        execute 'terminal'
        execute 'file ' . l:TerminalName
        for l:Mapping in s:MyTerminalMappings | execute l:Mapping | endfor
        for l:StartAction in l:StartActions
            call feedkeys(l:StartAction . "\<CR>", 'n')
        endfor
    endif
endfunction

function! s:make_terminal_name()
    if !exists('s:TerminalNumber') | let s:TerminalNumber = 0 | endif
    let s:TerminalNumber += 1
    return s:get_full_terminal_name(string(s:TerminalNumber))
endfunction

function! s:get_full_terminal_name(TerminalName)
    return 'Term: ' . a:TerminalName
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
            execute 'buffer! ' . l:BufferNumber
            return 'ok'
        else
            execute 'bwipeout ' . l:BufferNumber
            return 'error'
        endif
    else
        return 'error'
    endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Creates a terminal mode mapping only for terminals started through term#new(...)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#map(Lhs, Rhs, Remap=0)
    if !exists('s:MyTerminalMappings') | let s:MyTerminalMappings = [] | endif
    let l:Mapping = printf('%s <silent> <buffer> %s <C-\><C-n>%s',
                          \(a:Remap ? 'tmap' : 'tnoremap'),
                          \a:Lhs,
                          \a:Rhs
                         \)
    let s:MyTerminalMappings += [l:Mapping]
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Creates a mapping in both normal and terminal modes to start/go_to a terminal.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#define(Lhs, TerminalName, ...)
    let l:StartActions = a:000
    let l:Args = [a:TerminalName] + l:StartActions
    let l:QuotedArgs = map(l:Args, 'printf("\"%s\"", v:val)')
    let l:ArgsString = join(l:QuotedArgs, ',')
    exec printf('nnoremap <silent> %s :call call("term#new", [%s])<CR>', a:Lhs, l:ArgsString)
    call term#map(a:Lhs, printf(':execute (bufname("%") == "%s" ? "startinsert" : ''let b:LeftInTerminalMode=1 \| call call("term#new", [%s])'')<CR>', s:get_full_terminal_name(a:TerminalName), l:ArgsString))
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Automatically enter insert mode when entering a terminal window/buffer
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
        let l:FirstTime = !exists('b:NotFirstTime')
        if (l:FirstTime)
            startinsert
            let b:NotFirstTime = 'true'
        elseif exists('b:LeftInTerminalMode')
            unlet b:LeftInTerminalMode
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
" A hacky port of https://vimhelp.org/terminal.txt.html#term_sendkeys%28%29
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#send_keys(TargetBuffer, Keys)
    if !bufexists(a:TargetBuffer)
        throw 'TargetBuffer doesn''t exist'
    endif

    execute 'vsplit'
    execute 'buffer! ' . a:TargetBuffer
    startinsert
    call feedkeys(a:Keys, 'n')
    if getbufvar(a:TargetBuffer, '&buftype') == 'terminal'
        let l:GoToNormalMode = "\<C-\>\<C-n>"
    else
        let l:GoToNormalMode = "\<Esc>"
    endif
    call feedkeys(l:GoToNormalMode, 'n')
    call feedkeys(":q\<CR>", 'n')
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Move from terminal buffer window to another window. Example usage:
" call term#map('<C-j>', ':call term#move_to_window("j")<CR>')
" call term#map('<C-k>', ':call term#move_to_window("k")<CR>')
" call term#map('<C-h>', ':call term#move_to_window("h")<CR>')
" call term#map('<C-l>', ':call term#move_to_window("l")<CR>')
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#move_to_window(Direction)
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! term#go_to_alternate_buffer()
    let b:LeftInTerminalMode=1
    " A bit ugly to depend on another plugin
    if alternate_buffer#go() == -1
        unlet b:LeftInTerminalMode
        startinsert
    endif
endfunction
