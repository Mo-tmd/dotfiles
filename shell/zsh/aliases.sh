################################################################################
# Source aliases that are common between csh and sh
################################################################################
## First, put personal and work aliases in the same tmp file.
mkdir -p ~/dump
TmpCommonAliasesFile=~/dump/common_aliases_`uuidgen`
cp "${Dotfiles}/shell/aliases" $TmpCommonAliasesFile
WorkAliases="${WorkDotfiles}/shell/aliases"
if [[ -e "${WorkAliases}" ]]; then
    cat "${WorkAliases}" >> $TmpCommonAliasesFile
fi
unset WorkAliases

## Then convert to sh syntax and source.
TmpShAliasesFile=~/dump/sh_aliases_tmp_`uuidgen`
sed 's/{separator}/=/g' $TmpCommonAliasesFile > $TmpShAliasesFile
source $TmpShAliasesFile

## Cleanup
rm $TmpCommonAliasesFile
unset TmpCommonAliasesFile
rm $TmpShAliasesFile
unset TmpShAliasesFile

################################################################################
# sh specific
################################################################################
WorkShAliases="${WorkDotfiles}/shell/zsh/aliases.sh"
if [[ -e "${WorkShAliases}" ]]; then
    source "${WorkShAliases}"
fi
unset WorkShAliases

alias aliases='nvim "$Dotfiles"/shell/zsh/aliases.sh; source "$Dotfiles"/shell/zsh/aliases.sh'
alias saf='exec $0; source_tmux_conf.sh'
alias xd='export DISPLAY=`tmux show-env | sed -n 's/^OldDisplay=//p'`' ## Use X forwarding display.
alias ctd='export DISPLAY=`cat ~/citrix_displays/$HOST`'               ## Use Citrix display.
