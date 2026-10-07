#!/bin/bash
# Compatible with the Bash 3.2 shipped with macOS.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TARGET_HOME="${DOTFILES_TARGET_HOME:-$HOME}"
DRY_RUN=0
LINKS_ONLY=0
SYNC_NVIM=0
SET_SHELL=1
KEY_REPEAT=1
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --links-only) LINKS_ONLY=1 ;;
    --sync-nvim) SYNC_NVIM=1 ;;
    --default-shell) SET_SHELL=1 ;;
    --skip-shell) SET_SHELL=0 ;;
    --key-repeat) KEY_REPEAT=1 ;;
    --skip-key-repeat) KEY_REPEAT=0 ;;
    --help) cat <<'HELP'
Usage: bash bootstrap.sh [options]
  --dry-run        Show actions without changing anything
  --links-only     Link configs only; skip packages and plugin installs
  --sync-nvim      Also restore locked Neovim plugins (may run builds/install tools)
  --skip-shell     Skip setting Nushell as the default login shell
  --skip-key-repeat Skip applying faster macOS keyboard repeat settings
By default, register Nushell as the login shell and apply KeyRepeat=1,
InitialKeyRepeat=15. --links-only also skips both system settings.
Existing configs are backed up beside their original path. Reruns preserve links.
Requires macOS, Homebrew, and Xcode Command Line Tools for a full install.
HELP
      exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done
run() {
  if [ "$DRY_RUN" -eq 1 ]; then printf '[dry-run] '; printf '%q ' "$@"; printf '\n';
  else "$@"; fi
}
link_config() {
  local src="$1" dst="$2" backup
  if [ "$src" -ef "$dst" ]; then printf 'Already linked: %s\n' "$dst"; return; fi
  run mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup="${dst}.backup.$(date +%Y%m%d-%H%M%S).$$"
    run mv "$dst" "$backup"
  fi
  run ln -s "$src" "$dst"
}
if [ "$(uname -s)" != Darwin ]; then echo 'This bootstrap targets macOS.' >&2; exit 1; fi
if [ "$LINKS_ONLY" -eq 0 ]; then
  if ! command -v brew >/dev/null 2>&1; then
    if [ -x /opt/homebrew/bin/brew ]; then export PATH="/opt/homebrew/bin:$PATH";
    elif [ -x /usr/local/bin/brew ]; then export PATH="/usr/local/bin:$PATH";
    elif [ "$DRY_RUN" -eq 0 ]; then
      echo 'Install Homebrew from https://brew.sh, then rerun bootstrap.' >&2; exit 1
    fi
  fi
  if [ "$DRY_RUN" -eq 0 ]; then
    xcode-select -p >/dev/null 2>&1 || { echo 'Run xcode-select --install, complete installation, then rerun.' >&2; exit 1; }
  fi
  # Herdr may already be installed through its own installer.
  export PATH="$TARGET_HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
  if command -v herdr >/dev/null 2>&1; then
    # Avoid installing a second Herdr binary over a direct installation.
    if [ "$DRY_RUN" -eq 1 ]; then
      run brew bundle --file="$ROOT/Brewfile" --no-upgrade
    else
      TMP_BREWFILE="$(mktemp)"
      trap 'rm -f "$TMP_BREWFILE"' EXIT
      sed '/^brew "herdr"$/d' "$ROOT/Brewfile" > "$TMP_BREWFILE"
      run brew bundle --file="$TMP_BREWFILE" --no-upgrade
    fi
  else
    run brew bundle --file="$ROOT/Brewfile" --no-upgrade
  fi
  run mkdir -p "$TARGET_HOME/.local/share/atuin"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] atuin init nu > %s\n' "$TARGET_HOME/.local/share/atuin/init.nu"
  else
    ATUIN_TMP="$(mktemp "$TARGET_HOME/.local/share/atuin/init.nu.XXXXXX")"
    if atuin init nu > "$ATUIN_TMP"; then mv "$ATUIN_TMP" "$TARGET_HOME/.local/share/atuin/init.nu";
    else rm -f "$ATUIN_TMP"; exit 1; fi
  fi
  run mkdir -p "$TARGET_HOME/.local/share/zoxide"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] zoxide init nushell > %s\n' "$TARGET_HOME/.local/share/zoxide/init.nu"
  else
    ZOXIDE_TMP="$(mktemp "$TARGET_HOME/.local/share/zoxide/init.nu.XXXXXX")"
    if zoxide init nushell > "$ZOXIDE_TMP"; then mv "$ZOXIDE_TMP" "$TARGET_HOME/.local/share/zoxide/init.nu";
    else rm -f "$ZOXIDE_TMP"; exit 1; fi
  fi
fi
link_config "$ROOT/.config/nvim" "$TARGET_HOME/.config/nvim"
link_config "$ROOT/.tmux.conf" "$TARGET_HOME/.tmux.conf"
link_config "$ROOT/.config/herdr/config.toml" "$TARGET_HOME/.config/herdr/config.toml"
link_config "$ROOT/.config/atuin/config.toml" "$TARGET_HOME/.config/atuin/config.toml"
link_config "$ROOT/.config/nushell/config.nu" "$TARGET_HOME/Library/Application Support/nushell/config.nu"
link_config "$ROOT/.config/ghostty/config.ghostty" "$TARGET_HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
if [ "$LINKS_ONLY" -eq 0 ]; then
  if [ ! -d "$TARGET_HOME/.tmux/plugins/tpm" ]; then
    run git clone https://github.com/tmux-plugins/tpm "$TARGET_HOME/.tmux/plugins/tpm"
  fi
  run bash "$TARGET_HOME/.tmux/plugins/tpm/bin/install_plugins"
  run herdr plugin install paulbkim-dev/vim-herdr-navigation --ref 79679dacc791f70fc34de8b29a3cf9706c0f5b2f --yes
  run herdr plugin install thanhdat77/herdr-navigator --ref v0.3.3 --yes
  run herdr plugin enable vim-herdr-navigation
  run herdr plugin enable herdr-navigator
fi
if [ "$SYNC_NVIM" -eq 1 ]; then run nvim --headless '+Lazy! restore' +qa; fi
if [ "$SET_SHELL" -eq 1 ] && [ "$LINKS_ONLY" -eq 0 ]; then
  if [ "$DRY_RUN" -eq 1 ]; then echo '[dry-run] Register nu in /etc/shells and run chsh';
  else
    NU_PATH="$(command -v nu)"
    if ! grep -Fxq "$NU_PATH" /etc/shells; then printf '%s\n' "$NU_PATH" | sudo tee -a /etc/shells; fi
    chsh -s "$NU_PATH"
  fi
fi
if [ "$KEY_REPEAT" -eq 1 ] && [ "$LINKS_ONLY" -eq 0 ]; then
  run defaults write -g KeyRepeat -int 1
  run defaults write -g InitialKeyRepeat -int 15
fi
printf 'Bootstrap finished. Open a new terminal tab. Log out/in if key repeat changed.\n'
