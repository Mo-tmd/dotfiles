# rc file common for bot interactive and non interactive shells
source $ThisDir/variables.sh
unset ThisDir

[[ -e "$DotFiles"/.modules ]] && source "$DotFiles"/.modules
source "$DotFiles"/shell/zsh/aliases.sh
setup_symlinks.sh
