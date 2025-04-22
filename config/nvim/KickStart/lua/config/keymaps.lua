function Map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Lazy Keymap
Map('n', '<leader>lz', ':Lazy<CR>', { desc = 'Open Lazy' })
Map('n', '<leader>cm', ':Mason<CR>', { desc = 'Open Mason' })

-- Neotree Keymaps
Map('n', '<leader>e', ':Neotree reveal toggle<CR>', { desc = 'Toggle Neotree' })

-- Buffer Keymaps
Map('n', '<tab>', ':bnext<CR>', { desc = 'Next Buffer' })
Map('n', '<S-tab>', ':bprev<CR>', { desc = 'Previous Buffer' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
