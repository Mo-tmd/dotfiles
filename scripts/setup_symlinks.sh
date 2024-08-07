#!/bin/bash -e

CreateSymlink() {
    From=$1
    To=$2
    if [[ -L "${From}" && `readlink "${From}"` == "${To}" ]]; then
        : # Symlink already exists and is valid. Do nothing
    else
        if [[ -e "${From}" || -L "${From}" ]]; then
            Timestamp=`date +%F_%T`
            echo "Found ${From}, but it's not a valid symlink. Moving to ${From}${Timestamp}"
            mv "${From}" "${From}${Timestamp}"
        else
            echo "${From} is not found"
            mkdir -p `dirname "${From}"`
        fi
        echo "Creating symlink from ${From} to ${To}"
        ln -s "${To}" "${From}"
    fi
}

DotfilesDir=$1
[[ -e "${DotfilesDir}" ]] || { echo "Error, \"${DotfilesDir}\" doesn't exist"; exit 0; }

[[ -e ~/.cshrc.user || -L ~/.cshrc.user ]] && CshRcFile=~/.cshrc.user || CshRcFile=~/.cshrc
CreateSymlink $CshRcFile "${DotfilesDir}/shell/tcsh/rc.csh"

[[ -e ~/.zshrc.user || -L ~/.zshrc.user ]] && ZshRcFile=~/.zshrc.user || ZshRcFile=~/.zshrc
CreateSymlink $ZshRcFile "${DotfilesDir}/shell/zsh/rc.sh"

CreateSymlink ~/.zshenv "${DotfilesDir}/shell/zsh/.zshenv"
CreateSymlink ~/.config/nvim "${DotfilesDir}/nvim"
CreateSymlink ~/.tmux.conf "${DotfilesDir}/.tmux/.tmux.conf"
CreateSymlink ~/.tmux.conf.local "${DotfilesDir}/.tmux/.tmux.conf.local"
CreateSymlink ~/.screenrc "${DotfilesDir}/.screenrc"
CreateSymlink ~/.gitconfig "${DotfilesDir}/.gitconfig"
