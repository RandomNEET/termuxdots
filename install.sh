#!/usr/bin/env bash
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/RandomNEET/termuxdots/main/install.sh | bash
set -euo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/RandomNEET/termuxdots}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err() { echo -e "${RED}[ERR]${NC}   $*"; }
step() { echo -e "\n${CYAN}==>${NC} ${CYAN}$*${NC}"; }

CHEZMOI_DIR="$HOME/.local/share/chezmoi"

# prerequisites
step "Ensuring prerequisites"

for cmd in git; do
  if ! command -v "$cmd" &>/dev/null; then
    info "Installing $cmd…"
    pkg install -y "$cmd"
  fi
done

# clone
step "Cloning dotfiles repo"

if [[ ! -d "$CHEZMOI_DIR/.git" ]]; then
  info "Cloning into $CHEZMOI_DIR …"
  git clone "$REPO_URL" "$CHEZMOI_DIR"
else
  info "Updating existing repo…"
  if ! git -C "$CHEZMOI_DIR" pull --ff-only; then
    warn "Fast-forward failed — likely a force push. Resetting to remote…"
    git -C "$CHEZMOI_DIR" fetch origin
    git -C "$CHEZMOI_DIR" reset --hard "@{u}"
  fi
fi

# packages
step "Installing packages"

PKGLIST="$CHEZMOI_DIR/packages.list"

if [[ ! -f "$PKGLIST" ]]; then
  err "packages.list not found: $PKGLIST"
  exit 1
fi

mapfile -t PACKAGES < <(sed -E 's/#.*//; /^[[:space:]]*$/d' "$PKGLIST")

info "Updating pkg…"
pkg update -y >/dev/null 2>&1

info "Installing ${#PACKAGES[@]} packages…"
pkg install -y "${PACKAGES[@]}"

# dotfiles
step "Applying dotfiles"

if chezmoi status >/dev/null 2>&1; then
  info "Updating dotfiles…"
  chezmoi apply --force
else
  info "First run — initializing…"
  chezmoi init --apply --force
fi

# shell
step "Configuring shell"

if [[ "$SHELL" != *"zsh"* ]]; then
  info "Switching default shell to zsh…"
  chsh -s zsh
  info "Restart Termux to pick up the change."
else
  info "Already zsh."
fi

# zsh plugins
step "Setting up zsh plugins"

_gh_clone() {
  local dir="$1" repo="$2"
  if [[ ! -d "$dir" ]]; then
    git clone --depth=1 "$repo" "$dir"
  else
    echo "  ${dir##*/}: $(git -C "$dir" describe --tags --always 2>/dev/null || echo 'unknown')"
  fi
}

_gh_clone "$HOME/.local/share/zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
_gh_clone "$HOME/.local/share/zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

ZVM_DIR="$HOME/.local/share/zsh-vi-mode"
if [[ ! -d "$ZVM_DIR" ]]; then
  git clone --depth=1 "https://github.com/jeffreytse/zsh-vi-mode" "$ZVM_DIR"
  # fix for the escape-sequence style change in newer zsh
  sed -i "s/old_style =~ '.*\\\\a'/old_style == *\$'\\\\e]'[0-9]##';'*\$'\\\\a'/" \
    "$ZVM_DIR/zsh-vi-mode.zsh"
else
  echo "  zsh-vi-mode: $(git -C "$ZVM_DIR" describe --tags --always 2>/dev/null || echo 'unknown')"
fi

# storage
step "Setting up storage links"

if [[ ! -d "$HOME/storage/shared" ]]; then
  warn "Storage not set up. Running termux-setup-storage…"
  termux-setup-storage
  info "Storage permission granted. You may need to restart Termux."
fi

for pair in \
  "Download:dls" \
  "Documents:doc" \
  "Music:mus" \
  "Pictures:pic" \
  "Movies:vid"; do
  src="/storage/emulated/0/${pair%%:*}"
  dst="$HOME/${pair##*:}"

  if [[ -e "$dst" || -L "$dst" ]]; then
    rm -rf "$dst"
  fi

  if [[ -d "$src" ]]; then
    ln -s "$src" "$dst"
    info "  $dst → $src"
  else
    warn "  $src not found, skipping $dst"
  fi
done

# font
step "Installing font"

FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"
FONT_DEST="$HOME/.termux/font.ttf"

if [[ ! -f "$FONT_DEST" ]]; then
  info "Installing JetBrains Mono Nerd Font…"
  curl -fsSL -o "$FONT_DEST" "$FONT_URL"
  info "Done. Run 'termux-reload-settings' or restart Termux."
else
  info "Font already present."
fi

# motd
step "Writing MOTD"

MOTD_FILE="$PREFIX/etc/motd"
cat >"$MOTD_FILE" <<'MOTDEOF'
 _
| |_ ___ _ __ _ __ ___  _   ___  __
| __/ _ \ '__| '_ ` _ \| | | \ \/ /
| ||  __/ |  | | | | | | |_| |>  <
 \__\___|_|  |_| |_| |_|\__,_/_/\_\
MOTDEOF
info "MOTD written to $MOTD_FILE"

# done
echo -e "${GREEN}  dotfiles ready.${NC}"
