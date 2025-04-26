function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- Lazy Keymap
map("n", "<leader>lz", ":Lazy<CR>", { desc = "Open Lazy" })
map("n", "<leader>cm", ":Mason<CR>", { desc = "Open Mason" })

-- Neotree Keymaps
map("n", "<leader>e", ":Neotree reveal toggle<CR>", { desc = "Toggle Neotree" })

-- Buffer Keymaps
map("n", "<tab>", ":bnext<CR>", { desc = "Next Buffer" })
map("n", "<S-tab>", ":bprev<CR>", { desc = "Previous Buffer" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Replace Ctrl-C with Esc. Although its almost the same but not always.
map({ "i", "v", "x" }, "<C-c>", "<Esc>", { desc = "Replacement for Esc" })
