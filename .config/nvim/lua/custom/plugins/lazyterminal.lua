return {
  {
    dir = '/Users/aash/Developer/Personal/LazyTerminal',
    name = 'lazyterminal',
    config = function()
      require('lazyterminal').setup {
        tmux = {
          split = {
            direction = 'horizontal',
            size = '30%',
          },
        },
        keymaps = {
          launch = '<leader>aa',
          toggle = '<leader>at',
        },
        profiles = {
          claude = {
            args = { '--permission-mode', 'acceptEdits' },
          },
          codex = {
            args = { '-a', 'never', '-s', 'workspace-write' },
          },
        },
      }
    end,
  },
}
