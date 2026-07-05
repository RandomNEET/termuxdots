export GPG_TTY="$TTY"

if command -v gpg-connect-agent >/dev/null 2>&1; then
  gpg-connect-agent --quiet updatestartuptty /bye >/dev/null 2>&1
fi
