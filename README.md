# Dotfiles

Personal macOS setup: Ghostty, Nushell, Neovim, tmux, Herdr, Atuin, Arc, Rectangle, Spotifast, Codex CLI, and Claude Code CLI.

## Bootstrap

Install [Homebrew](https://brew.sh) and the Xcode Command Line Tools (`xcode-select --install`) first. Clone this repo wherever you want, then run from any shell:

```sh
bash ~/Developer/dotfiles/bootstrap.sh --dry-run
bash ~/Developer/dotfiles/bootstrap.sh
```

The script derives paths from its own location, installs packages in `Brewfile` without upgrading existing packages, generates Atuin's Nushell integration, links configs, and installs TPM and both Herdr plugins. Existing configs are moved to timestamped backups; correct links are left alone. A directly installed Herdr binary is kept rather than adding a second Homebrew installation. Herdr Navigator needs Rust to build, which is included in the package list.

By default, the script registers Nushell in `/etc/shells`, sets it as your account login shell, and applies macOS KeyRepeat=1 and InitialKeyRepeat=15. Shell setup can prompt for your password. Log out and back in to apply the keyboard settings.

Open a new terminal tab afterwards. Neovim installs its plugins on first launch; Mason installs configured language tools (Node/npm is included for oxfmt). To explicitly restore the Neovim lockfile, use `--sync-nvim`.

Options:

- `--dry-run`: show actions without modifying anything.
- `--links-only`: skip packages, Atuin generation, plugin installs, and shell/keyboard settings; useful after moving the repository. Requires dependencies and the Atuin init file to already exist.
- `--sync-nvim`: restore locked Neovim plugins headlessly, including plugin builds.
- `--skip-shell`: leave your account login shell unchanged.
- `--skip-key-repeat`: leave global keyboard settings unchanged.

Default paths assume macOS's standard configuration locations with no custom XDG settings. No GitHub authentication, SSH keys, or Atuin account credentials are copied. Use `gh auth login --git-protocol ssh --web` separately on new machines.

## Navigation

- Nushell: Vi editing, Neovim as editor, Homebrew and `~/.local/bin` on PATH.
- Atuin: Ctrl+R opens search in Vim normal mode; `i` enters search text.
- Neovim/tmux/Herdr: Ctrl+h/j/k/l navigate splits first and then surrounding panes.
- Herdr: Ctrl+b prefix; prefix+/ opens Herdr Navigator; prefix+d detaches.
- tmux: Ctrl+b prefix; prefix+I installs TPM plugins.

Herdr plugins are installed from [paulbkim-dev/vim-herdr-navigation](https://github.com/paulbkim-dev/vim-herdr-navigation) at a pinned commit and [thanhdat77/herdr-navigator](https://github.com/thanhdat77/herdr-navigator) v0.3.3. Neovim's Herdr bridge lives in `lua/custom/navigation.lua` and uses no machine-specific plugin checkout paths.

Only Herdr's `config.toml` is linked on new machines: plugin registries, sessions, sockets, and logs remain local and are ignored by Git. If you already linked the whole Herdr directory, the bootstrap preserves it and ignores its runtime files; migrate it when Herdr is stopped if you want runtime data outside the repo.

Moving this repo breaks existing absolute symlinks until you rerun `bash /new/location/bootstrap.sh --links-only`. Backups remain beside the replaced files or links.

## Checks

```sh
nu --version
nvim --version
npm --version
tree-sitter --version
herdr plugin action list --plugin vim-herdr-navigation
herdr plugin action list --plugin herdr-navigator
```

Inside Neovim run `:checkhealth`, and test Ctrl+h/j/k/l in a split and at its outer edge. Run `bash tests/bootstrap.sh` to verify config backup, relinking, and dry-run behavior in a temporary target directory without changing your real configs.

## Desktop apps and coding CLIs

`Brewfile` includes Arc, Rectangle, Spotifast (from `crmne/tap`), Codex CLI (`codex`), and Claude Code CLI (`claude-code`, the stable channel). The bootstrap installs missing packages and does not upgrade existing ones. Sign into Arc, Spotifast, Codex, and Claude Code separately after installation; grant Rectangle Accessibility permission when prompted.
