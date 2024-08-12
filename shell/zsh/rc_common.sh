# rc file common for both interactive and non interactive shells
GeneratedAliases=$(generate_aliases_or_variables_file.sh aliases ZSH "${Dotfiles}"/shell/aliases)
source "${GeneratedAliases}"
rm "${GeneratedAliases}"
unset GeneratedAliases

GeneratedVariables=$(generate_aliases_or_variables_file.sh variables ZSH "${Dotfiles}"/shell/variables)
source "${GeneratedVariables}"
rm "${GeneratedVariables}"
unset GeneratedVariables

[[ -n "${WorkDotfiles}" ]] && setup_symlinks.sh "${WorkDotfiles}" || setup_symlinks.sh "${Dotfiles}"
