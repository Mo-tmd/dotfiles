""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Wrapper around system() function. It removes the new line character at the
" end of the output (displayed as ^@)
" See https://superuser.com/a/935646
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! SystemCmd(...)
    let output = call('system', a:000)
    return substitute(output, '\n$', '', '')
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Prints buffer variables and some 'famous' options/properties to a file.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! PrintBufferInfoToFile(file_name)
    " Initialize an empty list to hold all lines of output
    let output = []

    " Collect buffer-local variables
    call add(output, 'Buffer Variables:')
    for key in keys(b:)
        call add(output, key . ': ' . string(get(b:, key)))
    endfor

    " Collect buffer options and properties
    call add(output, '')
    call add(output, 'Buffer Options and Properties:')
    call add(output, 'bufhidden: ' . &l:bufhidden)
    call add(output, 'buflisted: ' . &l:buflisted)
    call add(output, 'bufname: ' . bufname())
    call add(output, 'buftype: ' . &l:buftype)
    call add(output, 'filetype: ' . &l:filetype)
    call add(output, 'modifiable: ' . &l:modifiable)
    call add(output, 'readonly: ' . &l:readonly)
    call add(output, 'swapfile: ' . &l:swapfile)
    call add(output, '-------------------------------')

    " Write the output list to the specified file
    call writefile(output, a:file_name, 'a')
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Removes an element from a list or a blob.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RemoveElement(list_or_blob, value, end=v:null)
    let index = index(a:list_or_blob, a:value)
    if index != -1
        if a:end != v:null
            return remove(a:list_or_blob, index, a:end)
        else
            return remove(a:list_or_blob, index)
        endif
    else
        return a:list_or_blob
    endif
endfunction
