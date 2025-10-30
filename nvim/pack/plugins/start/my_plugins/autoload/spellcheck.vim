function spellcheck#setup()
endfunction

let g:SpellDir = stdpath('data') . '/spellcheck'
let s:SpellExcludedFilesDb = g:SpellDir . '/excluded_files_db'

set spellcapcheck= spelllang=en_us
exec 'set spellfile=' . g:SpellDir . '/general.en.add'

nnoremap <silent> <leader>cs :call ToggleSpellCheck()<CR>

autocmd TermOpen * setlocal nospell
autocmd BufEnter * call MaybeEnableSpell()
function! MaybeEnableSpell()
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

function! ToggleSpellCheck()
    if !filereadable(s:SpellExcludedFilesDb)
        call mkdir(g:SpellDir, 'p')
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
