# rc file common for both interactive and non interactive shells
source "${Dotfiles}/shell/zsh/variables.sh"
source "${Dotfiles}/shell/zsh/aliases.sh"
[[ -n "${WorkDotfiles}" ]] && setup_symlinks.sh "${WorkDotfiles}" || setup_symlinks.sh "${Dotfiles}"
