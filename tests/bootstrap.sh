#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT
TARGET="$TEST_ROOT/target"
mkdir -p "$TARGET/.config/atuin" "$TARGET/.config" "$TARGET/.tmux"
printf 'original config\n' > "$TARGET/.config/atuin/config.toml"
ln -s "$TEST_ROOT/missing-nvim" "$TARGET/.config/nvim"
DOTFILES_TARGET_HOME="$TARGET" bash "$ROOT/bootstrap.sh" --links-only --dry-run > "$TEST_ROOT/dry.log"
[ "$(cat "$TARGET/.config/atuin/config.toml")" = 'original config' ]
[ "$(readlink "$TARGET/.config/nvim")" = "$TEST_ROOT/missing-nvim" ]
[ ! -e "$TARGET/.tmux.conf" ]
DOTFILES_TARGET_HOME="$TARGET" bash "$ROOT/bootstrap.sh" --links-only > "$TEST_ROOT/first.log"
[ "$(readlink "$TARGET/.config/nvim")" = "$ROOT/.config/nvim" ]
[ "$(readlink "$TARGET/.tmux.conf")" = "$ROOT/.tmux.conf" ]
[ "$(readlink "$TARGET/.config/herdr/config.toml")" = "$ROOT/.config/herdr/config.toml" ]
[ ! -L "$TARGET/.config/herdr" ]
[ "$(readlink "$TARGET/Library/Application Support/nushell/config.nu")" = "$ROOT/.config/nushell/config.nu" ]
[ "$(readlink "$TARGET/Library/Application Support/com.mitchellh.ghostty/config.ghostty")" = "$ROOT/.config/ghostty/config.ghostty" ]
BACKUP="$(find "$TARGET/.config/atuin" -name 'config.toml.backup.*')"
[ "$(cat "$BACKUP")" = 'original config' ]
COUNT="$(find "$TARGET" -name '*.backup.*' | wc -l | tr -d ' ')"
DOTFILES_TARGET_HOME="$TARGET" bash "$ROOT/bootstrap.sh" --links-only > "$TEST_ROOT/second.log"
[ "$COUNT" = "$(find "$TARGET" -name '*.backup.*' | wc -l | tr -d ' ')" ]
# A repo directory with spaces can be relocated and relinked.
COPY="$TEST_ROOT/moved dotfiles"
mkdir -p "$COPY"
cp "$ROOT/bootstrap.sh" "$COPY/"
mkdir -p "$COPY/.config/herdr"
for config in nvim atuin nushell ghostty; do cp -R "$ROOT/.config/$config" "$COPY/.config/"; done
cp "$ROOT/.config/herdr/config.toml" "$COPY/.config/herdr/"
cp "$ROOT/.tmux.conf" "$COPY/"
DOTFILES_TARGET_HOME="$TARGET" bash "$COPY/bootstrap.sh" --links-only > "$TEST_ROOT/moved.log"
[ "$TARGET/.config/nvim" -ef "$COPY/.config/nvim" ]
echo 'Passed: dry run, backups, idempotence, file-only Herdr link, and relocation with spaces.'
