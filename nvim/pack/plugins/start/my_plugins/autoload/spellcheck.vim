""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Global/Script variables
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:spell_dir = stdpath('data') . '/spellcheck'
let s:spell_excluded_files_db = g:spell_dir . '/excluded_files_db'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup function
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! spellcheck#setup()
    call mkdir(g:spell_dir, 'p')

    set spellcapcheck= spelllang=en_us
    execute 'set spellfile=' . g:spell_dir . '/general.en.add'

    nnoremap <silent> <leader>cs :call <SID>toggle_spell_check()<CR>

    augroup NeovimSpellCheck
        autocmd!
        autocmd TermOpen * setlocal nospell
        autocmd BufEnter * call <SID>maybe_enable_spell()
    augroup END
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Local functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Automatically enable or disable spellcheck based on the exclusion database.
function! s:maybe_enable_spell()
    if ! &modifiable | return | endif

    let path = expand('%:p')
    let is_excluded_from_spell =
        \ path != '' &&
        \ filereadable(s:spell_excluded_files_db) &&
        \ index(readfile(s:spell_excluded_files_db), path) >= 0

    setlocal spelloptions=camel
    if is_excluded_from_spell
        setlocal nospell
    else
        setlocal spell
    endif
endfunction

" Toggle spellcheck for the current file and update the exclusion database.
function! s:toggle_spell_check()
    if !filereadable(s:spell_excluded_files_db)
        call writefile([], s:spell_excluded_files_db)
    endif

    let excluded_files = readfile(s:spell_excluded_files_db)
    let current_file = expand('%:p')
    if &spell
        setlocal nospell
        if index(excluded_files, current_file) == -1
            call writefile([current_file], s:spell_excluded_files_db, 'a')
        endif
    else
        setlocal spell
        if index(excluded_files, current_file) >= 0
            call remove(excluded_files, index(excluded_files,current_file))
            call writefile(excluded_files, s:spell_excluded_files_db)
        endif
    endif
endfunction
