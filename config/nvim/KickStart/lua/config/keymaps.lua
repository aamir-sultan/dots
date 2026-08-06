-- `local` on purpose: this used to define a global `map`, which leaked into
-- every Lua file and tripped lua_ls' undefined/global-write diagnostics.
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- Lazy Keymap
map("n", "<leader>lz", ":Lazy<CR>", { desc = "Open Lazy" })
map("n", "<leader>cm", ":Mason<CR>", { desc = "Open Mason" })

-- NOTE: <leader>e (Neo-tree) lives in plugins/neo-tree.lua. It used to be
-- defined here twice and in plugins/snacks.lua as well.

-- Buffer Keymaps
map("n", "<tab>", ":bnext<CR>", { desc = "Next Buffer" })
map("n", "<S-tab>", ":bprev<CR>", { desc = "Previous Buffer" })

--  See `:help wincmd` for a list of all window commands
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Move cursor charachter down" })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Move cursor charachter up" })

-- NOTE: plain <C-hjkl> window-navigation maps used to be defined here and then
-- immediately overwritten at the bottom of this file by nvim-tmux-navigation.
-- Only the tmux-aware versions remain (see the end of this file).

-- Exits to normal mode from visual
map("v", "ii", "<C-c>", { desc = "Exits to normal mode from visual" })
-- vim.keymap.set("v", "ii", "<C-c>")
-- Fix * (Keep the cursor position, don't move to next match)
map("n", "*", "*N", { desc = "Keep the cursor position, don't move to next match" })

-- leader-o/O inserts blank line below/above
map("n", "<leader>o", "o<ESC>", { desc = "Create new line below this line" })
map("n", "<leader>O", "O<ESC>", { desc = "Create new line below this line" })

-- Mimic shell movements
map("i", "<C-E>", "<C-o>$", { desc = "Jump to line End -- Mimic shell movement" })
map("i", "<C-A>", "<C-o>^", { desc = "Jump to line Start -- Mimic shell movement" })

-- Shortcut to yank register.
-- NOTE: this was on <leader>p, which is redefined further down as `"*p`, so it
-- was dead. Moved to <leader>P so both are reachable.
map({ "n", "x" }, "<leader>P", '"0p', { desc = "[P]aste from yank register" })

-- Keymaps for better default experience
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Replace Ctrl-C with Esc. Although its almost the same but not always.
map({ "n", "v", "i", "x" }, "<C-c>", "<Esc>", { desc = "Replacement for Esc" })

map({ "n" }, "<leader>tn", "<Esc>:set nornu! nonu!<CR>", { desc = "[T]oggle line [N]umbering" })
map({ "n" }, "<leader>tb", ":let &bg=(&bg=='light'?'dark':'light')<cr>", { desc = "[T]oggle [B]ackground" })
map({ "n" }, "<leader>th", "<esc>:set nohlsearch!<CR>", { desc = "[T]oggle search [H]ighlight" })
map({ "n" }, "<leader>tw", "<esc>:set wrap!<CR>", { desc = "[T]oggle line [W]rapping" })

map({ "n" }, "<leader>yp", "<esc>:let @\" = expand('%:p')<CR>", { desc = "[Y]ank current file [P]ath" })
map({ "n" }, "<leader>cp", "<esc>:let @* = expand('%:p')<CR>", { desc = "[C]opy current file [P]ath" })
map({ "n" }, "<leader>cr", "<esc>:let @* = expand('%')<CR>", { desc = "[C]opy [R]elative file path" })
map({ "n" }, "<leader>cf", "<esc>:let @* = expand('%:t')<CR>", { desc = "[C]opy [F]ile" })
map({ "v" }, "<leader>yy", '"*y', { desc = "[C]opy current [S]election" })
map({ "n" }, "<leader>p", '"*p', { desc = "[P]aste contents of * register" })

map("n", "<leader>ww", "<cmd>w<CR>", { desc = "Save Current Buffer" })
map("n", "<leader>wo", "<C-W>p", { desc = "Other window" })
map("n", "--", "<C-^>", { desc = "Toggle window to last active buffer" })

-- NOTE: ~100 lines of fully commented-out ToggleTerm / Neoscroll / Harpoon /
-- Telescope mappings used to live here, along with a top-level
-- `require("nvim-tmux-navigation")` that forced the plugin to load eagerly on
-- every startup. The <C-hjkl> tmux-aware navigation now lives in its own lazy
-- spec: plugins/tmux-navigation.lua
