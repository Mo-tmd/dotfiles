## Source common aliases
mkdir -p ~/dump
set File=~/dump/csh_aliases_tmp_`uuidgen`
sed 's/{separator}/ /g' "$DotFiles"/shell/aliases > $File
source $File

rm $File
unset File

## csh specific
alias aliases 'nvim "$DotFiles"/shell/tcsh/aliases.csh; source "$DotFiles"/shell/tcsh/aliases.csh'
alias saf 'source "$DotFiles"/shell/tcsh/rc.csh; source_tmux_conf.sh'
alias xd 'setenv DISPLAY `tmux show-env | sed -n 's/^OldDisplay=//p'`' ## Use X forwarding display.
alias ctd 'setenv DISPLAY `cat ~/citrix_displays/$HOST`'               ## Use Citrix display.
