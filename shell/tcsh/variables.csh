## Source common variables
set File=~/dump/csh_variables_tmp_`uuidgen`
sed 's/{env_var}/setenv/g' ~/dotfiles/shell/variables | \
sed 's/{separator}/ /g'                               | \
sed 's/{shell_var}/set /g'                              \
> $File
source $File

rm $File
unset File

## csh specific
set HIST="~/.history"
set histdup=erase # Remove duplicate entries in history
set savehist=(500 merge lock)

