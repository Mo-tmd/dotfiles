################################################################################
# Stuff that needs to be in the beginning
################################################################################
if (! $?Dotfiles) then
    if (-e ~/.cshrc.user) then
        set ThisFile = ~/.cshrc.user
    else
        set ThisFile = ~/.cshrc
    endif
    set ThisFile = `readlink -f $ThisFile`
    set ThisDir = `dirname "${ThisFile}"`
    unset ThisFile
    setenv Dotfiles `readlink -f "${ThisDir}/../.."`
    unset ThisDir
endif

################################################################################
# Set variables and aliases etc
################################################################################
source "${Dotfiles}/shell/tcsh/variables.csh"
source "${Dotfiles}/shell/tcsh/aliases.csh"
if ($?WorkDotfiles) then
    setup_symlinks.sh "${WorkDotfiles}"
else
    setup_symlinks.sh "${Dotfiles}"
endif

################################################################################
# Key bindings
################################################################################
bindkey -e
bindkey "^F" forward-word
bindkey "^B" backward-word
bindkey "^D" delete-word
bindkey "^V" backward-delete-word # Any better suggestions?
bindkey "^K" kill-whole-line
bindkey "^P" history-search-backward
bindkey "^N" history-search-forward
bindkey "^X" dabbrev-expand

################################################################################
# Misc
################################################################################
set histfile = ~/dump/.history
unset rprompt
