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
setenv PATH `"${Dotfiles}/scripts/path/set_path.sh" "${Dotfiles}/shell/path"`

################################################################################
# Main
################################################################################
set GeneratedAliases = `generate_aliases_or_variables_file.sh aliases tcsh "${Dotfiles}"/shell/aliases`
source "${GeneratedAliases}"
rm "${GeneratedAliases}"
unset GeneratedAliases

set GeneratedVariables = `generate_aliases_or_variables_file.sh variables tcsh "${Dotfiles}"/shell/variables`
source "${GeneratedVariables}"
rm "${GeneratedVariables}"
unset GeneratedVariables

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
unset rprompt
