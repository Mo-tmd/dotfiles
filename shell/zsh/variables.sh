################################################################################
# Source variables that are common between csh and sh
################################################################################
## First, put personal and work variables in the same tmp file.
mkdir -p ~/dump
TmpCommonVariablesFile=~/dump/common_variables_`uuidgen`
cp "${DotFiles}/shell/variables" $TmpCommonVariablesFile
WorkVariables="${WorkDotFiles}/shell/variables"
if [[ -e "${WorkVariables}" ]]; then
    cat "${WorkVariables}" >> $TmpCommonVariablesFile
fi
unset WorkVariables

## Then convert to sh syntax and source.
TmpShVariablesFile=~/dump/sh_variables_tmp_`uuidgen`
sed 's/{env_var}/export/g' "${TmpCommonVariablesFile}" | \
sed 's/{separator}/=/g'                                | \
sed 's/{shell_var}//g'                                   \
> $TmpShVariablesFile
source $TmpShVariablesFile

## Cleanup
rm $TmpCommonVariablesFile
unset TmpCommonVariablesFile
rm $TmpShVariablesFile
unset TmpShVariablesFile

################################################################################
# sh specific
################################################################################
WorkShVariables="${WorkDotFiles}/shell/zsh/variables.sh"
if [[ -e "${WorkShVariables}" ]]; then
    source "${WorkShVariables}"
fi
unset WorkShVariables

