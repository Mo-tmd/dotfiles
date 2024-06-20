# If interactive shell, do nothing.
# If not interactive shell, source rc file.
[[ $- == *i* ]] && : || source ~/.zshrc
