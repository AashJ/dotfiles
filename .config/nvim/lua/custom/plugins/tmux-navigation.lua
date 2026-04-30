---@module 'lazy'
---@type LazySpec
return {
  'christoomey/vim-tmux-navigator',
  cmd = {
    'TmuxNavigateLeft',
    'TmuxNavigateDown',
    'TmuxNavigateUp',
    'TmuxNavigateRight',
    'TmuxNavigatePrevious',
    'TmuxNavigatorProcessList',
  },
  keys = {
    { '<C-h>', '<cmd><C-U>TmuxNavigateLeft<CR>', desc = 'Move to the left split or tmux pane' },
    { '<C-j>', '<cmd><C-U>TmuxNavigateDown<CR>', desc = 'Move to the lower split or tmux pane' },
    { '<C-k>', '<cmd><C-U>TmuxNavigateUp<CR>', desc = 'Move to the upper split or tmux pane' },
    { '<C-l>', '<cmd><C-U>TmuxNavigateRight<CR>', desc = 'Move to the right split or tmux pane' },
    { '<C-\\>', '<cmd><C-U>TmuxNavigatePrevious<CR>', desc = 'Move to the previous split or tmux pane' },
  },
}
