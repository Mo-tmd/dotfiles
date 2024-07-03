################################################################################
# Source variables that are common between csh and sh
################################################################################
## First, put personal and work variables in the same tmp file.
mkdir -p ~/dump
set TmpCommonVariablesFile = ~/dump/common_variables_`uuidgen`
cp "${Dotfiles}/shell/variables" $TmpCommonVariablesFile
if ($?WorkDotfiles) then
    set WorkVariables = "${WorkDotfiles}/shell/variables"
    if (-e "${WorkVariables}") then
        cat "${WorkVariables}" >> $TmpCommonVariablesFile
    endif
    unset WorkVariables
endif

## Then convert to csh syntax and source.
set TmpCshVariablesFile = ~/dump/csh_variables_tmp_`uuidgen`
sed 's/{env_var}/setenv/g' "${TmpCommonVariablesFile}" | \
sed 's/{separator}/ /g'                                | \
sed 's/{shell_var}/set /g'                               \
> $TmpCshVariablesFile
source $TmpCshVariablesFile

## Cleanup
rm $TmpCommonVariablesFile
unset TmpCommonVariablesFile
rm $TmpCshVariablesFile
unset TmpCshVariablesFile

################################################################################
# csh specific
################################################################################
if ($?WorkDotfiles) then
    set WorkCshVariables = "${WorkDotfiles}/shell/tcsh/variables.csh"
    if (-e "${WorkCshVariables}") then
        source "${WorkCshVariables}"
    endif
    unset WorkCshVariables
endif

set HIST = "~/.history"
set histdup = erase # Remove duplicate entries in history
set savehist = (500 merge lock)

