## Source common variables
mkdir -p ~/dump
File=~/dump/sh_variables_tmp_`uuidgen`
sed 's/{env_var}/export/g' "${DotFiles}/shell/variables" | \
sed 's/{separator}/=/g'                                  | \
sed 's/{shell_var}//g'                                     \
> $File
source $File

rm $File
unset File

## sh specific
if [[ ! -n "${TBOX_SESSION}" ]]; then
    export KUBECONFIG=$MY_KUBECONFIG
fi
