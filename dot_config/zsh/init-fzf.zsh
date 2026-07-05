if [[ -f "$PREFIX/share/fzf/key-bindings.zsh" ]]; then
  source "$PREFIX/share/fzf/key-bindings.zsh"
fi

if [[ -f "$PREFIX/share/fzf/completion.zsh" ]]; then
  source "$PREFIX/share/fzf/completion.zsh"
fi

export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git 2>/dev/null || find . -type d"

# Override the placeholder declared in init-zvm.zsh
function _zvm_fzf_init() {
  zvm_bindkey viins '^T' fzf-file-widget
  zvm_bindkey viins '^R' fzf-history-widget
  zvm_bindkey viins '\ec' fzf-cd-widget
}
