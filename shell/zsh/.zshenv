# Set the "Dotfiles" environment variable.
if [[ ! -v Dotfiles ]]; then
    [[ -e ~/.zshrc.user ]] && ThisFile=~/.zshrc.user || ThisFile=~/.zshrc
    ThisFile=$(readlink -f $ThisFile)
    ThisDir=$(dirname "$ThisFile")
    export Dotfiles=$(readlink -f "$ThisDir/../..")
    unset ThisFile
    unset ThisDir
fi

# Set the "PATH" environment variable.
PATH=`"$Dotfiles/scripts/path/set_path" "$Dotfiles/shell/path"`

# Set aliases and variables only if we are in a non-interactive shell.
# For interactive shells, they will be set in rc.zsh
if [[ $- != *i* ]]; then
    source "$Dotfiles/shell/zsh/set_aliases_and_variables.zsh" "$Dotfiles" ""
fi
