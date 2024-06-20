# af-magic.zsh-theme
#
# Author: Andy Fleming
# URL: http://andyfleming.com/

# dashed separator size
function afmagic_dashes {
  # check either virtualenv or condaenv variables
  local python_env_dir="${VIRTUAL_ENV:-$CONDA_DEFAULT_ENV}"
  local python_env="${python_env_dir##*/}"

  # if there is a python virtual environment and it is displayed in
  # the prompt, account for it when returning the number of dashes
  if [[ -n "$python_env" && "$PS1" = *\(${python_env}\)* ]]; then
    echo $(( COLUMNS - ${#python_env} - 3 ))
  else
    echo $COLUMNS
  fi
}

# primary prompt: dashed separator, extra user prompt, and current dir
PS1="${FG[237]}\${(l.\$(afmagic_dashes)..-.)}%{$reset_color%}
"
if type 'ExtraPrompt' 2>/dev/null | grep -q 'function'; then
  PS1+="${FG[240]}\$(ExtraPrompt)%{$reset_color%}
"
fi
#PS1+="${FG[032]}%~
PS1+="${FG[247]}%~
${FG[105]}%(!.#.❯❯)%{$reset_color%} "

PS2="%{$fg[red]%}\ %{$reset_color%}"

# right prompt: return code, virtualenv and context (user@host)
RPS1="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
if (( $+functions[virtualenv_prompt_info] )); then
  RPS1+='$(virtualenv_prompt_info)'
fi
RPS1+=" ${FG[237]}%n@%m%{$reset_color%}"

# git settings
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""

# hg settings
ZSH_THEME_HG_PROMPT_PREFIX=""
ZSH_THEME_HG_PROMPT_CLEAN=""
ZSH_THEME_HG_PROMPT_DIRTY=""
ZSH_THEME_HG_PROMPT_SUFFIX=""

# virtualenv settings
ZSH_THEME_VIRTUALENV_PREFIX=" ${FG[075]}["
ZSH_THEME_VIRTUALENV_SUFFIX="]%{$reset_color%}"
