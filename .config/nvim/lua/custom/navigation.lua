-- Herdr handles the outer panes; this handles Neovim windows and their edges.
local M = {}
local directions = {
  h = { 'left', 'Left' }, j = { 'down', 'Down' },
  k = { 'up', 'Up' }, l = { 'right', 'Right' },
}
function M.move(key)
  local direction = directions[key]
  if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= '' then
    local previous = vim.api.nvim_get_current_win()
    vim.cmd('wincmd ' .. key)
    if vim.api.nvim_get_current_win() == previous then
      local binary = vim.env.HERDR_BIN_PATH
      if not binary or binary == '' then binary = 'herdr' end
      vim.fn.system({ binary, 'pane', 'focus', '--direction', direction[1], '--pane', vim.env.HERDR_PANE_ID })
      if vim.v.shell_error ~= 0 then
        vim.notify('Herdr pane navigation failed', vim.log.levels.WARN)
      end
    end
  elseif vim.env.TMUX and vim.env.TMUX ~= '' then
    vim.cmd('TmuxNavigate' .. direction[2])
  else
    vim.cmd('wincmd ' .. key)
  end
end
function M.setup()
  for key, direction in pairs(directions) do
    vim.keymap.set('n', '<C-' .. key .. '>', function() M.move(key) end,
      { silent = true, desc = 'Move to the ' .. direction[1] .. ' split or pane' })
  end
  vim.keymap.set('n', '<C-\\>', '<cmd>TmuxNavigatePrevious<CR>', { silent = true, desc = 'Previous tmux pane' })
end
return M
