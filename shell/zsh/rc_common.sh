# rc file common for bot interactive and non interactive shells
ThisDir=$0:A:h
source $ThisDir/variables.sh
unset ThisDir

source "$DotFiles"/.modules
source "$DotFiles"/shell/zsh/aliases.sh
setup_symlinks.sh
