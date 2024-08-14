# rc file common for both interactive and non interactive shells

################################################################################
# Variables and aliases
################################################################################
GeneratedFilesDir=~/dump/zsh/aliases_and_variables
mkdir -p "${GeneratedFilesDir}"

GeneratedAliases="${GeneratedFilesDir}/aliases"
generate_aliases_or_variables_file.sh aliases ZSH "${Dotfiles}"/shell/aliases "${GeneratedAliases}"
source "${GeneratedAliases}"
unset GeneratedAliases

GeneratedVariables="${GeneratedFilesDir}/variables"
generate_aliases_or_variables_file.sh variables ZSH "${Dotfiles}"/shell/variables "${GeneratedVariables}"
source "${GeneratedVariables}"
unset GeneratedVariables
unset GeneratedFilesDir

################################################################################
# Setup symlinks
################################################################################
[[ -n "${WorkDotfiles}" ]] && setup_symlinks.sh "${WorkDotfiles}" || setup_symlinks.sh "${Dotfiles}"
