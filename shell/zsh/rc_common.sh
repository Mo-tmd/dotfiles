# rc file common for both interactive and non interactive shells
source "${Dotfiles}/shell/zsh/variables.sh"
source "${Dotfiles}/shell/zsh/aliases.sh"
[[ $SkipSymlinksSetup == true ]] || setup_symlinks.sh "${Dotfiles}"
