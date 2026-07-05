if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons auto --color auto --git --group-directories-first --header'
  alias ll='eza -l --icons auto --color auto --git --group-directories-first'
  alias la='eza -la --icons auto --color auto --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons auto'
  alias l='eza -l --icons auto'
fi
