#!/bin/bash -e

CreateSymlink() {
    From=$1
    To=$2
    if [[ -L $From && `readlink $From` == $To ]]; then
        : # Symlink already exists and is valid. Do nothing
    else
        if [[ -e $From || -L $From ]]; then
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

DotFilesDir=$1
[[ -e "${DotFilesDir}" ]] || { echo "Error, \"${DotFilesDir}\" doesn't exist"; exit 0; }

[[ -e ~/.cshrc.user ]] && CshRcFile=~/.cshrc.user || CshRcFile=~/.cshrc
CreateSymlink $CshRcFile "${DotFilesDir}/shell/tcsh/rc.csh"

[[ -e ~/.zshrc.user ]] && ZshRcFile=~/.zshrc.user || ZshRcFile=~/.zshrc
CreateSymlink $ZshRcFile "${DotFilesDir}/shell/zsh/rc.sh"

CreateSymlink ~/.zshenv "${DotFilesDir}/shell/zsh/.zshenv"
CreateSymlink ~/.config/nvim "${DotFilesDir}/nvim"
CreateSymlink ~/.tmux.conf "${DotFilesDir}/.tmux/.tmux.conf"
CreateSymlink ~/.tmux.conf.local "${DotFilesDir}/.tmux/.tmux.conf.local"
CreateSymlink ~/.screenrc "${DotFilesDir}/.screenrc"
CreateSymlink ~/.gitconfig "${DotFilesDir}/.gitconfig"
