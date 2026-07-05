if [[ -f "$HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history)
fi
