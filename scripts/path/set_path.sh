#!/bin/bash -e

ThisDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) ## Stolen from https://stackoverflow.com/a/246128
source "${ThisDir}/add_to_path.sh"

PathFile=$1
while IFS= read -r Line; do
    Line=$(eval echo $Line)
    add_to_path "${Line}"
done <<<$(grep -v '^\s*#' "${PathFile}")

echo $PATH
