

function Map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end


-- Neotree Keympas
 Map("n", "<leader>e", ":Neotree reveal toggle<CR>", { desc = "Toggle Neotree" })
