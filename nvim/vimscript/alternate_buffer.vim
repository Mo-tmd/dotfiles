"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Improves C-^ functionality while still keeping behavior similar to native vim.
"   * Handles wiped out buffers
"   * Falls back to a global buffer history if no buffer is found in the
"     window history.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <silent> <C-^> :call GoToAlternateBuffer()<CR>
function! GoToAlternateBuffer()
    let l:AlternateBuffer = GetAlternateBuffer()
    if l:AlternateBuffer != -1
        execute 'buffer ' . l:AlternateBuffer
        return 0
    else
        echohl ErrorMsg
        echo "E23: No alternate file"
        echohl NONE
        return -1
    endif
endfunction

function! GetAlternateBuffer()
    let l:Buffers = s:GlobalBufferHistory + get(s:WindowsBufferHistory,win_getid())
    for l:Buffer in reverse(l:Buffers)
        if bufexists(l:Buffer) && l:Buffer != bufnr()
            return l:Buffer
        endif
    endfor
    return -1
endfunction

autocmd BufWinEnter,WinEnter * call UpdateBufferHistory()
function! UpdateBufferHistory()
    call UpdateWindowsBufferHistory()
    call UpdateGlobalBufferHistory()
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keeps a window specific buffer history (buffers visited inside specific windows).
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! UpdateWindowsBufferHistory()
    if !exists('s:WindowsBufferHistory') | let s:WindowsBufferHistory = {} | endif
    let l:Win = win_getid()
    let l:Buffer = bufnr()
    let l:WindowBufferHistory= get(s:WindowsBufferHistory, l:Win, [])
    call RemoveElement(l:WindowBufferHistory, l:Buffer)
    call add(l:WindowBufferHistory, l:Buffer)
    let s:WindowsBufferHistory[l:Win] = l:WindowBufferHistory
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keeps a global buffer history (not specific to windows). GoToAlternateBuffer()
" falls back to it if there are no existing buffers in the window specific history.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! UpdateGlobalBufferHistory()
    if !exists('s:GlobalBufferHistory') | let s:GlobalBufferHistory = [] | endif
    let l:Buffer = bufnr()
    call RemoveElement(s:GlobalBufferHistory, l:Buffer)
    call add(s:GlobalBufferHistory, l:Buffer)
endfunction
