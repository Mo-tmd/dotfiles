#!/bin/bash -e

CreateSymlink() {
    From=$1
    To=$2
    if [[ -L $From && `readlink $From` == $To ]]; then
        : # Symlink already exists and is valid. Do nothing
    else
        if [[ -e $From ]]; then
            Timestamp=`date +%F_%T`
            echo "Found ${From}, but it's not a valid symlink. Moving to ${From}${Timestamp}"
            mv $From $From$Timestamp
        else
            echo "${From} is not found"
        fi
        echo "Creating symlink from ${From} to ${To}"
        ln -s "$To" "$From"
    fi
}

CreateSymlink ~/.cshrc "$DotFiles"/shell/tcsh/rc.csh
CreateSymlink ~/.zshrc "$DotFiles"/shell/zsh/rc.sh
CreateSymlink ~/.zshenv "$DotFiles"/shell/zsh/.zshenv
CreateSymlink ~/.config/nvim "$DotFiles"/nvim
CreateSymlink ~/.tmux.conf "$DotFiles"/.tmux/.tmux.conf
CreateSymlink ~/.tmux.conf.local "$DotFiles"/.tmux/.tmux.conf.local
CreateSymlink ~/.screenrc "$DotFiles"/.screenrc
CreateSymlink ~/.gitconfig "$DotFiles"/.gitconfig
