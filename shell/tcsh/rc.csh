################################################################################
# Stuff that needs to be in the beginning
################################################################################
if (! $?Dotfiles) then
    if (-e ~/.cshrc.user) then
        set ThisFile = ~/.cshrc.user
    else
        set ThisFile = ~/.cshrc
    endif
    set ThisFile = `readlink -f $ThisFile`
    set ThisDir = `dirname "${ThisFile}"`
    unset ThisFile
    setenv Dotfiles `readlink -f "${ThisDir}/../.."`
    unset ThisDir
endif

################################################################################
# Set DISPLAY
################################################################################
if ($?OldDisplay || ! $?prompt) then
    ## Either DISPLAY has already been set to Citrix, or
    ## running a non-interactive shell. Do nothing
    :
else
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
    endif
    unset CitrixDisplayFile
endif

################################################################################
# Set variables and aliases etc
################################################################################
source "${Dotfiles}/shell/tcsh/variables.csh"
source "${Dotfiles}/shell/tcsh/aliases.csh"
if ($?SkipSymlinksSetup) then
    if ($SkipSymlinksSetup == true) then
        :
    else
        setup_symlinks.sh "${Dotfiles}"
    endif
else
    setup_symlinks.sh "${Dotfiles}"
endif

################################################################################
# Key bindings
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

