################################################################################
# Set the "Dotfiles" environment variable.
################################################################################
if [[ -z "$Dotfiles" ]]; then
    [[ -e ~/.bashrc.user ]] && ThisFile=~/.bashrc.user || ThisFile=~/.bashrc
    ThisFile=$(readlink -f "$ThisFile")
    ThisDir=$(dirname "$ThisFile")
    export Dotfiles=$(readlink -f "$ThisDir/../..")
    unset ThisFile
    unset ThisDir
fi

################################################################################
# Set the "PATH" environment variable.
################################################################################
PATH=$("$Dotfiles/scripts/path/set_path" "$Dotfiles/shell/path")

################################################################################
# Set aliases and variables.
################################################################################
source "$Dotfiles/shell/set_aliases_and_variables.sh" "$Dotfiles" "" bash

################################################################################
# Key bindings
################################################################################
set -o vi
