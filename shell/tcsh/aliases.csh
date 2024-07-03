################################################################################
## Source aliases that are common between csh and sh
################################################################################
## First, put personal and work aliases in the same tmp file.
mkdir -p ~/dump
set TmpCommonAliasesFile = ~/dump/common_aliases_`uuidgen`
cp "${DotFiles}/shell/aliases" $TmpCommonAliasesFile
if ($?WorkDotFiles) then
    set WorkAliases = "${WorkDotFiles}/shell/aliases"
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
## csh specific
################################################################################
if ($?WorkDotFiles) then
    set WorkCshAliases = "${WorkDotFiles}/shell/tcsh/aliases.csh"
    if (-e "${WorkCshAliases}") then
        source "${WorkCshAliases}"
    endif
    unset WorkCshAliases
endif

alias aliases 'nvim "$DotFiles"/shell/tcsh/aliases.csh; source "$DotFiles"/shell/tcsh/aliases.csh'
alias saf 'source "$DotFiles"/shell/tcsh/rc.csh; source_tmux_conf.sh'
alias xd 'setenv DISPLAY `tmux show-env | sed -n 's/^OldDisplay=//p'`' ## Use X forwarding display.
alias ctd 'setenv DISPLAY `cat ~/citrix_displays/$HOST`'               ## Use Citrix display.
