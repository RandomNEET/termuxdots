typeset -U path cdpath fpath manpath
path=(
  "$HOME/.local/bin"
  "$PREFIX/bin"
  $path
)
fpath=(
  "$PREFIX/share/zsh/functions/Completion"
  "$PREFIX/share/zsh/site-functions"
  $fpath
)
HELPDIR="$PREFIX/share/zsh/$ZSH_VERSION/help"

autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

HISTSIZE="100000"
SAVEHIST="100000"
HISTFILE="$HOME/.local/share/zsh/history"
mkdir -p "$(dirname "$HISTFILE")"

set_opts=(
  AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT EXTENDED_GLOB GLOB_DOTS
  HIST_FCNTL_LOCK HIST_IGNORE_ALL_DUPS HIST_IGNORE_DUPS HIST_IGNORE_SPACE
  HIST_SAVE_NO_DUPS SHARE_HISTORY NO_APPEND_HISTORY NO_EXTENDED_HISTORY
  NO_HIST_EXPIRE_DUPS_FIRST NO_HIST_FIND_NO_DUPS
)
for opt in "${set_opts[@]}"; do
  setopt "$opt"
done
unset opt set_opts

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
