$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.config.buffer_editor = "nvim"
$env.config.edit_mode = "vi"
# Support Apple Silicon and Intel Homebrew, plus direct Herdr installs.
$env.PATH = ($env.PATH | prepend [($env.HOME | path join ".local" "bin") /opt/homebrew/bin /opt/homebrew/sbin /usr/local/bin /usr/local/sbin] | uniq)
source ~/.local/share/atuin/init.nu
