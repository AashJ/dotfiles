---@module 'lazy'
---@type LazySpec
return {
  'sindrets/diffview.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  cmd = {
    'DiffviewOpen',
    'DiffviewClose',
    'DiffviewFileHistory',
    'DiffviewFocusFiles',
    'DiffviewRefresh',
    'DiffviewToggleFiles',
  },
  keys = {
    { '<leader>do', '<cmd>DiffviewOpen<CR>', desc = '[D]iff [O]pen' },
    { '<leader>dc', '<cmd>DiffviewClose<CR>', desc = '[D]iff [C]lose' },
    { '<leader>df', '<cmd>DiffviewToggleFiles<CR>', desc = '[D]iff Toggle [F]iles' },
    { '<leader>dr', '<cmd>DiffviewRefresh<CR>', desc = '[D]iff [R]efresh' },
    { '<leader>dh', '<cmd>DiffviewFileHistory %<CR>', desc = '[D]iff File [H]istory' },
    { '<leader>dH', '<cmd>DiffviewFileHistory<CR>', desc = '[D]iff Repo [H]istory' },
  },
  opts = {},
}
