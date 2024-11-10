"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Wrapper around system() function. It removes the new line character at the
" end of the output (displayed as ^@)
" See https://superuser.com/a/935646
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! SystemCmd(...)
    let l:Output = call('system', a:000)
    return substitute(l:Output, '\n$', '', '')
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Prints buffer variables and some 'famous' options/properties to a file.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! PrintBufferInfoToFile(FileName)
    " Initialize an empty list to hold all lines of output
    let l:Output = []

    " Collect buffer-local variables
    call add(l:Output, "Buffer Variables:")
    for l:Key in keys(b:)
        call add(l:Output, l:Key . ': ' . string(get(b:, l:Key)))
    endfor

    " Collect buffer options and properties
    call add(l:Output, '')
    call add(l:Output, "Buffer Options and Properties:")
    call add(l:Output, 'bufhidden: ' . &l:bufhidden)
    call add(l:Output, 'buflisted: ' . &l:buflisted)
    call add(l:Output, 'bufname: ' . bufname('%'))
    call add(l:Output, 'buftype: ' . &l:buftype)
    call add(l:Output, 'filetype: ' . &l:filetype)
    call add(l:Output, 'modifiable: ' . &l:modifiable)
    call add(l:Output, 'readonly: ' . &l:readonly)
    call add(l:Output, 'swapfile: ' . &l:swapfile)
    call add(l:Output, '-------------------------------')

    " Write the output list to the specified file
    call writefile(l:Output, a:FileName, "a")
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Removes an element from a list or a blob.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RemoveElement(ListOrBlob, Value, End=v:null)
    let l:Index = index(a:ListOrBlob, a:Value)
    if l:Index != -1
        if a:End != v:null
            return remove(a:ListOrBlob, l:Index, a:End)
        else
            return remove(a:ListOrBlob, l:Index)
        endif
    else
        return a:ListOrBlob
    endif
endfunction
