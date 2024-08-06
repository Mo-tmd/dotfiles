################################################################################
# Source aliases that are common between csh and sh
################################################################################
## First, put personal and work aliases in the same tmp file.
mkdir -p ~/dump
set TmpCommonAliasesFile = ~/dump/common_aliases_`uuidgen`
cp "${Dotfiles}/shell/aliases" $TmpCommonAliasesFile
if ($?WorkDotfiles) then
    set WorkAliases = "${WorkDotfiles}/shell/aliases"
    if (-e "${WorkAliases}") then
        cat "${WorkAliases}" >> $TmpCommonAliasesFile
    endif
    unset WorkAliases
endif

## Then convert to csh syntax and source.
set TmpCshAliasesFile = ~/dump/csh_aliases_tmp_`uuidgen`
sed 's/{separator}/ /g' $TmpCommonAliasesFile > $TmpCshAliasesFile
source $TmpCshAliasesFile

## Cleanup
rm $TmpCommonAliasesFile
unset TmpCommonAliasesFile
rm $TmpCshAliasesFile
unset TmpCshAliasesFile

################################################################################
# csh specific
################################################################################
alias e 'bash -c "[[ -n "\${NVIM}" ]] && nvr \!* || nvim \!*"'
alias saf 'source "$Dotfiles"/shell/tcsh/rc.csh; source_tmux_conf.sh'

if ($?WorkDotfiles) then
    set WorkCshAliases = "${WorkDotfiles}/shell/tcsh/aliases.csh"
    if (-e "${WorkCshAliases}") then
        source "${WorkCshAliases}"
    endif
    unset WorkCshAliases
endif

