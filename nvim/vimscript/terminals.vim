"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Start/go_to a terminal. Usage examples:
"     * :Term Terminal name
"     * :call Terminal('Terminal name', 'Start action', 'Another start action')
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! -nargs=? Term call Terminal(<q-args>)
command! -nargs=? TermHere call Terminal(<q-args>, 'cd '.expand('%:h'))
function! Terminal(...)
    if len(a:000) > 0
        let l:TerminalName = (len(a:000[0]) > 0 ? GetFullTerminalName(a:000[0]) : MakeTerminalName())
        let l:StartActions = a:000[1:]
    else
        let l:TerminalName = MakeTerminalName()
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

function! MakeTerminalName()
    if !exists('s:TerminalNumber') | let s:TerminalNumber = 0 | endif
    let s:TerminalNumber += 1
    return GetFullTerminalName(string(s:TerminalNumber))
endfunction

function! GetFullTerminalName(TerminalName)
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Creates a terminal mode mapping only for terminals started through Terminal(...)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! Tmap(Lhs, Rhs, Remap=0)
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
function! CreateMapForStartingTerminal(Lhs, TerminalName, ...)
    let l:StartActions = a:000
    let l:Args = [a:TerminalName] + l:StartActions
    let l:QuotedArgs = map(l:Args, 'printf("\"%s\"", v:val)')
    let l:ArgsString = join(l:QuotedArgs, ',')
    exec printf('nnoremap <silent> %s :call call("Terminal", [%s])<CR>', a:Lhs, l:ArgsString)
    call Tmap(a:Lhs, printf(':execute (bufname("%") == "%s" ? "startinsert" : ''let b:LeftInTerminalMode=1 \| call call("Terminal", [%s])'')<CR>', GetFullTerminalName(a:TerminalName), l:ArgsString))
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Automatically enter insert mode when entering a terminal window/buffer
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
    if &buftype == 'terminal'
        let l:FirstTime = !exists('b:NotFirstTime')
        if (l:FirstTime)
            startinsert
            let b:NotFirstTime = 'true'
        elseif exists('b:LeftInTerminalMode')
            unlet b:LeftInTerminalMode
            startinsert
        elseif (line('.') >= GetLastNonEmptyLine())
            startinsert
        endif
    elseif &filetype != 'TelescopePrompt' && &filetype != 'alpha'
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
" A hacky port of https://vimhelp.org/terminal.txt.html#term_sendkeys%28%29
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! TermSendKeys(TargetBuffer, Keys)
    if !bufexists(a:TargetBuffer)
        throw 'TargetBuffer doesn''t exist'
    endif

    execute 'vsplit'
    execute 'buffer ' . a:TargetBuffer
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
" Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call Tmap('<C-^>', ':call TerminalGoToAlternateBuffer()<CR>')
function! TerminalGoToAlternateBuffer()
    let b:LeftInTerminalMode=1
    if GoToAlternateBuffer() == -1
        unlet b:LeftInTerminalMode
        startinsert
    endif
endfunction

call CreateMapForStartingTerminal('<leader>td', 'Dotfiles', 'cd ~/dotfiles')
