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
# Variables and aliases
################################################################################
set GeneratedFilesDir=~/dump/tcsh/aliases_and_variables
mkdir -p "${GeneratedFilesDir}"

set GeneratedAliases="${GeneratedFilesDir}/aliases"
generate_aliases_or_variables_file.sh aliases tcsh "${Dotfiles}"/shell/aliases "${GeneratedAliases}"
source "${GeneratedAliases}"
unset GeneratedAliases

set GeneratedVariables="${GeneratedFilesDir}/variables"
generate_aliases_or_variables_file.sh variables tcsh "${Dotfiles}"/shell/variables "${GeneratedVariables}"
source "${GeneratedVariables}"
unset GeneratedVariables
unset GeneratedFilesDir

################################################################################
# Setup symlinks
################################################################################
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
