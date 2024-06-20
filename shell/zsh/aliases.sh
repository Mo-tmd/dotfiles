## Source common aliases
mkdir -p ~/dump
File=~/dump/sh_aliases_tmp_`uuidgen`
sed 's/{separator}/=/g' "$DotFiles"/shell/aliases > $File
source $File

rm $File
unset File

## sh specific
alias aliases='nvim "$DotFiles"/shell/zsh/aliases.sh; source "$DotFiles"/shell/zsh/aliases.sh'
alias saf='exec $0; source_tmux_conf.sh'
alias xd='export DISPLAY=`tmux show-env | sed -n 's/^OldDisplay=//p'`' ## Use X forwarding display.
alias ctd='export DISPLAY=`cat ~/citrix_displays/$HOST`'               ## Use Citrix display.
