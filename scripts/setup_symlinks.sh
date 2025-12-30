#!/bin/bash -e

create_symlink() {
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
create_symlink $CshRcFile "${DotfilesDir}/shell/tcsh/rc.tcsh"

[[ -e ~/.zshrc.user || -L ~/.zshrc.user ]] && ZshRcFile=~/.zshrc.user || ZshRcFile=~/.zshrc
create_symlink $ZshRcFile "${DotfilesDir}/shell/zsh/rc.zsh"

create_symlink ~/.zshenv "${DotfilesDir}/shell/zsh/.zshenv"
create_symlink ~/.config/nvim "${DotfilesDir}/nvim"
create_symlink ~/.tmux.conf "${DotfilesDir}/.tmux/.tmux.conf"
create_symlink ~/.tmux.conf.local "${DotfilesDir}/.tmux/.tmux.conf.local"
create_symlink ~/.screenrc "${DotfilesDir}/.screenrc"
create_symlink ~/.gitconfig "${DotfilesDir}/.gitconfig"
create_symlink ~/.config/kitty/kitty.conf "${DotfilesDir}/kitty.conf"
create_symlink ~/.local/share/fonts "${DotfilesDir}/fonts"
