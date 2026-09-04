""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Improves C-^ functionality while still keeping behavior similar to native vim.
"   * Handles wiped out buffers
"   * Falls back to a global buffer history if no buffer is found in the
"     window history.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! alternate_buffer#go()
    let alternate_bufnr = alternate_buffer#get()
    if alternate_bufnr != -1
        execute 'buffer! ' . alternate_bufnr
        return 0
    else
        echohl ErrorMsg
        echo 'E23: No alternate file'
        echohl NONE
        return -1
    endif
endfunction

function! alternate_buffer#get()
    let bufnrs = s:global_buffer_history + get(s:windows_buffer_history,win_getid())
    for bufnr in reverse(bufnrs)
        if bufexists(bufnr) && bufnr != bufnr()
            return bufnr
        endif
    endfor
    return -1
endfunction

autocmd BufWinEnter,WinEnter * call s:update_buffer_history()
function! s:update_buffer_history()
    call s:update_windows_buffer_history()
    call s:update_global_buffer_history()
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keeps a window specific buffer history (buffers visited inside specific windows).
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:update_windows_buffer_history()
    if !exists('s:windows_buffer_history') | let s:windows_buffer_history = {} | endif
    let win = win_getid()
    let bufnr = bufnr()
    let window_buffer_history = get(s:windows_buffer_history, win, [])
    call RemoveElement(window_buffer_history, bufnr)
    call add(window_buffer_history, bufnr)
    let s:windows_buffer_history[win] = window_buffer_history
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keeps a global buffer history (not specific to windows). GoToAlternateBuffer()
" falls back to it if there are no existing buffers in the window specific history.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:update_global_buffer_history()
    if !exists('s:global_buffer_history') | let s:global_buffer_history = [] | endif
    let bufnr = bufnr()
    call RemoveElement(s:global_buffer_history, bufnr)
    call add(s:global_buffer_history, bufnr)
endfunction
