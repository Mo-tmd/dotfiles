#!/bin/bash -e

mkdir -p ~/dump
AliasesOrVariables=$1
Shell="${2,,}" # Tranform to lower case.
InputFile=$3
OutputFile="${HOME}/dump/${AliasesOrVariables}_`uuidgen`.${Shell}"

function extract_section() {
    Section=$1
    # Explanation for the awk below because I will probably not understand it after a few days:
    # * Put all lines in "lines" array
    # * Search for the section. "start" is the line before (the header).
    # * Search for the header of the next section. It is the second separator after "start". "end" is the line before.
    # * If "end" is not defined, it's because the section we're looking for is the last one. So make "end" the last line.
    # * print all lines between start and end
    awk "{lines[NR] = \$0} \
         /${Section}/ {start = NR-1} \
         /################################################################################/ { if (start && NR>start+2) {end=NR-1;exit} } \
         END { \
             if (end); else end=NR; \
             for (i=start; i<=end; i++) {print lines[i]} \
         }" \
         "${InputFile}" \
    >> "${OutputFile}"
}

if [[ $AliasesOrVariables == aliases ]]; then
    extract_section "Aliases common for all shells"
    if [[ $Shell == zsh ]]; then
        sed -i 's/{separator}/=/g' "${OutputFile}"
        extract_section "Aliases specific to ZSH"
    fi
    if [[ $Shell == tcsh ]]; then
        sed -i 's/{separator}/ /g' "${OutputFile}"
        extract_section "Aliases specific to TCSH"
    fi
fi

if [[ $AliasesOrVariables == variables ]]; then
    extract_section "Variables common for all shells"
    if [[ $Shell == zsh ]]; then
        sed -i -e 's/{env_var}/export/g' \
               -e 's/{separator}/=/g'    \
               -e 's/{shell_var}//g'     \
               "${OutputFile}"
        extract_section "Variables specific to ZSH"
    fi
    if [[ $Shell == tcsh ]]; then
        sed -i -e 's/{env_var}/setenv/g' "${OutputFile}" \
               -e 's/{separator}/ /g'                    \
               -e 's/{shell_var}/set /g'                 \
               "${OutputFile}"
        extract_section "Variables specific to TCSH"
    fi
fi

echo "${OutputFile}"

