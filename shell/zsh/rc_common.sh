# rc file common for both interactive and non interactive shells
source "${DotFiles}/shell/zsh/variables.sh"
source "${DotFiles}/shell/zsh/aliases.sh"
[[ $SkipSymlinksSetup == true ]] || setup_symlinks.sh "${DotFiles}"
