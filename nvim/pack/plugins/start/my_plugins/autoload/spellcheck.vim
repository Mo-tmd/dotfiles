""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Global/Script variables
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:SpellDir = stdpath('data') . '/spellcheck'
let s:SpellExcludedFilesDb = g:SpellDir . '/excluded_files_db'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup function
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! spellcheck#setup()
    call mkdir(g:SpellDir, 'p')

    set spellcapcheck= spelllang=en_us
    execute 'set spellfile=' . g:SpellDir . '/general.en.add'

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

    let l:Path = expand('%:p')
    let l:IsExcludedFromSpell =
        \ l:Path != '' &&
        \ filereadable(s:SpellExcludedFilesDb) &&
        \ index(readfile(s:SpellExcludedFilesDb), l:Path) >= 0

    setlocal spelloptions=camel
    if l:IsExcludedFromSpell
        setlocal nospell
    else
        setlocal spell
    endif
endfunction

" Toggle spellcheck for the current file and update the exclusion database.
function! s:toggle_spell_check()
    if !filereadable(s:SpellExcludedFilesDb)
        call writefile([], s:SpellExcludedFilesDb)
    endif

    let l:ExcludedFiles = readfile(s:SpellExcludedFilesDb)
    let l:CurrentFile = expand('%:p')
    if &spell
        setlocal nospell
        if index(l:ExcludedFiles, l:CurrentFile) == -1
            call writefile([l:CurrentFile], s:SpellExcludedFilesDb, 'a')
        endif
    else
        setlocal spell
        if index(l:ExcludedFiles, l:CurrentFile) >= 0
            call remove(l:ExcludedFiles, index(l:ExcludedFiles,l:CurrentFile))
            call writefile(l:ExcludedFiles, s:SpellExcludedFilesDb)
        endif
    endif
endfunction
