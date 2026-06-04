DotfilesDir=$1
Prefix=$2
Shell=$3

GeneratedFilesDir="$HOME/dump/$Shell/aliases_and_variables"
mkdir -p "$GeneratedFilesDir"

GeneratedAliases="$GeneratedFilesDir/${Prefix}aliases"
generate_aliases_or_variables_file aliases "$Shell" "$DotfilesDir"/shell/aliases "$GeneratedAliases"
source "$GeneratedAliases"

GeneratedVariables="$GeneratedFilesDir/${Prefix}variables"
generate_aliases_or_variables_file variables "$Shell" "$DotfilesDir"/shell/variables "$GeneratedVariables"
source "$GeneratedVariables"

unset GeneratedAliases
unset GeneratedVariables
unset GeneratedFilesDir
unset DotfilesDir
unset Prefix
unset Shell
