ZVM_DIR="$HOME/.local/share/zsh-vi-mode"

if [[ ! -f "$ZVM_DIR/zsh-vi-mode.plugin.zsh" ]]; then
  echo "zsh-vi-mode: not found, skipping" >&2
  return
fi

function zvm_config() {
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  ZVM_SYSTEM_CLIPBOARD_ENABLED=true
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
  ZVM_VI_VISUAL_ESCAPE_BINDKEY=jk
  ZVM_VI_HIGHLIGHT_FOREGROUND=black
  ZVM_VI_HIGHLIGHT_BACKGROUND=white
}

source "$ZVM_DIR/zsh-vi-mode.plugin.zsh"

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

function _zvm_after_init() {
  zvm_bindkey vicmd 'k' up-line-or-beginning-search
  zvm_bindkey vicmd 'j' down-line-or-beginning-search
  zvm_bindkey viins '^[[A' up-line-or-beginning-search
  zvm_bindkey viins '^[[B' down-line-or-beginning-search
}
zvm_after_init_commands+=(_zvm_after_init)

# fzf init hook
# Declares placeholder function; actual content filled by init-fzf.zsh
function _zvm_fzf_init() {
  # Overridden by init-fzf.zsh
  :
}
zvm_after_init_commands+=(_zvm_fzf_init)
