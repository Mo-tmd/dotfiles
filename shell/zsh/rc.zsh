################################################################################
# Stuff that needs to be in the beginning
################################################################################
if [[ ! -v Dotfiles ]]; then
    [[ -e ~/.zshrc.user ]] && ThisFile=~/.zshrc.user || ThisFile=~/.zshrc
    ThisFile=$(readlink -f $ThisFile)
    ThisDir=$(dirname "${ThisFile}")
    unset ThisFile
    export Dotfiles=$(readlink -f "${ThisDir}/../..")
else
    ThisDir="${Dotfiles}/shell/zsh"
fi

PATH=`"${Dotfiles}/scripts/path/set_path.sh" "${Dotfiles}/shell/path"`

################################################################################
# Source rc_common.zsh if running a non-interactive shell.
################################################################################
if [[ $- == *i* ]]; then
    # Interactive shell, do nothing (continue)
    :
else
    # Non interactive shell, source common rc and exit script.
    source "${ThisDir}/rc_common.zsh"
    unset ThisDir
    return
fi

################################################################################
# Pre Oh My Zsh
################################################################################
export ZSH_COMPDUMP="${HOME}/dump/zsh/zcompdump-${HOST}-${ZSH_VERSION}"
mkdir -p `dirname $ZSH_COMPDUMP`

# Disables some check that shows strange errors.
export ZSH_DISABLE_COMPFIX="true"

#function ExtraPrompt() {
#    echo "hello"
#}

# Used by zsh-syntax-highlighting plugin.
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=105'
ZSH_HIGHLIGHT_STYLES[path]='fg=105,underline'

################################################################################
################################################################################
############################# BEGIN Oh My Zsh ##################################
################################################################################
################################################################################
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="${ThisDir}/ohmyzsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="mo-af-magic"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="${ThisDir}/ohmyzsh_custom"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git gitfast zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
################################################################################
################################################################################
############################## END Oh My Zsh ###################################
################################################################################
################################################################################
source "${ThisDir}/rc_common.zsh"
unset ThisDir

HISTFILE=~/dump/.zsh_history

unset RPS1

#Key bindings
export KEYTIMEOUT=21
bindkey -v

#Use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

bindkey ';dw' kill-word
bindkey ';a' end-of-line
bindkey ';i' beginning-of-line
bindkey ';b' backward-word
bindkey ';w' forward-word

# Kill buffer
function KillBuffer() {
    zle end-of-history
    zle kill-buffer
}
zle -N KillBuffer
bindkey '^U' KillBuffer

# Kill buffer in vicmd mode
function KillBufferVicmdMode() {
    KillBuffer
    zle vi-insert
}
zle -N KillBufferVicmdMode
bindkey -M vicmd '^U' KillBufferVicmdMode

