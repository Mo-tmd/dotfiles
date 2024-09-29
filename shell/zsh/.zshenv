if [[ $- == *i* ]]; then
    : # Interactive shell, do nothing.
else
    # Non-interactive shell, source rc file
    [[ -e ~/.zshrc.user ]] && source ~/.zshrc.user || source ~/.zshrc
fi
