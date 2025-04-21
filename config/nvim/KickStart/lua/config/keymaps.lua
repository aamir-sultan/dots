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
