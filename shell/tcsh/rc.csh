################################################################################
## Set Display
################################################################################
if ($?OldDisplay || ! $?prompt) then
    ## Either DISPLAY has already been set to Citrix, or
    ## running a non-interactive shell. Do nothing
    :
else
    echo 'mo tcsh: setting DISPLAY'
    ## This is the first login shell. i.e. not a subshell
    ## Set OldDisplay to DISPLAY (probably X forwarding)
    if ($?DISPLAY) then
        setenv OldDisplay $DISPLAY
    else
        setenv OldDisplay "None"
    endif
    ## If running in Citrix, save/update its DISPLAY in a file.
    set CitrixDisplaysDir = "$HOME/citrix_displays"
    set CitrixDisplayFile = "$CitrixDisplaysDir/$HOST"
    if ($?CITRIX_DISPLAY) then
        if (! -e $CitrixDisplaysDir) then
            mkdir $CitrixDisplaysDir
        endif
        unset CitrixDisplaysDir
        if (! -e $CitrixDisplayFile) then
            touch $CitrixDisplayFile
        endif
        if ($CITRIX_DISPLAY != `cat ~/citrix_displays/$HOST`) then
            ## The file is empty or out of date, update/set it.
            echo $CITRIX_DISPLAY > $CitrixDisplayFile
        endif
    endif

    ## Finally, set DISPLAY to Citrix by reading the file.
    if (-e $CitrixDisplayFile) then
        setenv DISPLAY `cat ~/citrix_displays/$HOST`
    else
        echo "Error, $CitrixDisplayFile not found"
    endif
    unset CitrixDisplayFile
endif

################################################################################
## Set variables and aliases etc
################################################################################
source ~/dotfiles/shell/tcsh/variables.csh
source "$DotFiles"/shell/tcsh/aliases.csh
source "$DotFiles"/.modules
setup_symlinks.sh

################################################################################
## Key bindings
################################################################################
bindkey -e
bindkey "^F" forward-word
bindkey "^B" backward-word
bindkey "^D" delete-word
bindkey "^V" backward-delete-word # Any better suggestions?
bindkey "^K" kill-whole-line
bindkey "^P" history-search-backward
bindkey "^N" history-search-forward
bindkey "^X" dabbrev-expand

