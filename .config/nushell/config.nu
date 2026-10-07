$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "vi"
# Support Apple Silicon and Intel Homebrew, direct Herdr installs, Bun globals, and Nix.
$env.PATH = ($env.PATH | prepend [($env.HOME | path join ".local" "bin") ($env.HOME | path join ".bun" "bin") ($env.HOME | path join ".nix-profile" "bin") /nix/var/nix/profiles/default/bin /opt/homebrew/bin /opt/homebrew/sbin /usr/local/bin /usr/local/sbin] | uniq)
source ~/.local/share/atuin/init.nu
source ~/.local/share/zoxide/init.nu
alias j = z
# direnv has no Nushell init script, so load its environment before each prompt.
$env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt? | default [] | append {||
  if (which direnv | is-empty) { return }
  direnv export json | from json | default {} | load-env
  if ($env.PATH | describe) == "string" {
    $env.PATH = ($env.PATH | split row (char esep))
  }
})
