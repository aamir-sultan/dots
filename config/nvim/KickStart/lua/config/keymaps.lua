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

-- Shortcut to yank register
map({ "n", "x" }, "<leader>p", '"0p', { desc = "Paste from yank register" })

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
map({ "n" }, "<leader>yy", '"*y', { desc = "[C]opy current [S]election" })
map({ "n" }, "<leader>p", '"*p', { desc = "[P]aste contents of * register" })

-- -- *************************************************-
-- Default Disables
-- *************************************************-
-- Disabled keys -- Ctrl + hjkl are disabled for config instead the following will be used.
-- Move to window using the <ctrl> hjkl keys
-- map("n", "<C-h>", ":<C-U>TmuxNavigateLeft<cr>", { desc = "Go to left window either tmux or nvim" })
-- map("n", "<C-j>", ":<C-U>TmuxNavigateDown<cr>", { desc = "Go to lower window either tmux or nvim" })
-- map("n", "<C-k>", ":<C-U>TmuxNavigateUp<cr>", { desc = "Go to upper window either tmux or nvim" })
-- map("n", "<C-l>", ":<C-U>TmuxNavigateRight<cr>", { desc = "Go to right window either tmux or nvim" })
--

map("n", "<leader>ww", "<cmd>w<CR>", { desc = "Save Current Buffer" })
map("n", "<leader>wo", "<C-W>p", { desc = "Other window" })
map("n", "--", "<C-^>", { desc = "Toggle window to last active buffer" })

-- Neotree Keympas
map("n", "<leader>e", ":Neotree reveal toggle<CR>", { desc = "Toggle Neotree" })

-- ToggleTerm Keympas
-- map({ 'n' }, "<leader>tt", ":ToggleTerm<CR>", { desc = "Toggle floating terminal" })
-- map({ 't' }, "<leader>tt", "<Esc><cmd>ToggleTerm<CR>", { desc = "Toggle floating terminal" })
--
-- -- NeoScroll Settings
-- map({ "n", "v", "x" }, "<C-d>", function()
-- 	require("neoscroll").ctrl_d({ duration = 100 })
-- end, { desc = "Ctrl+d half screen down scroll" })
-- map({ "n", "v", "x" }, "<C-u>", function()
-- 	require("neoscroll").ctrl_u({ duration = 100 })
-- end, { desc = "Ctrl+u half screen up scroll" })
-- map({ "n", "v", "x" }, "<C-f>", function()
-- 	require("neoscroll").ctrl_f({ duration = 100 })
-- end, { desc = "Ctrl+f full screen down scroll" })
-- map({ "n", "v", "x" }, "<C-b>", function()
-- 	require("neoscroll").ctrl_b({ duration = 100 })
-- end, { desc = "Ctrl+b full screen up scroll" })
-- map({ "n", "v", "x" }, "<C-y>", function()
-- 	require("neoscroll").scroll(-0.1, { move_cursor = false, duration = 100 })
-- end, { desc = "Few Lines up scroll" })
-- map({ "n", "v", "x" }, "<C-e>", function()
-- 	require("neoscroll").scroll(0.1, { move_cursor = false, duration = 100 })
-- end, { desc = "Few Lines down scroll" })
-- map({ "n", "v", "x" }, "zz", function()
-- 	require("neoscroll").zz({ half_win_duration = 50 })
-- end, { desc = "Reposition cursor to the middle of the screen" })
-- map({ "n", "v", "x" }, "zt", function()
-- 	require("neoscroll").zt({ half_win_duration = 50 })
-- end, { desc = "Reposition cursor to the top of the screen" })
-- map({ "n", "v", "x" }, "zb", function()
-- 	require("neoscroll").zb({ half_win_duration = 50 })
-- end, { desc = "Reposition cursor to the bottom of the screen" })

local nvim_tmux_nav = require("nvim-tmux-navigation")

vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)

-- Optional: setup the plugin if not done by your plugin manager
-- nvim_tmux_nav.setup {
--   disable_when_zoomed = true,
-- }

-- Harpoon Keys
-- This setting works with lazy loading of Harpoon
-- map('n', "<leader>A", function() require("harpoon"):list():add() end, { desc = "harpoon file" })
-- map('n', "<leader>a", function()
--   local harpoon = require("harpoon")
--   harpoon.ui:toggle_quick_menu(harpoon:list())
-- end, { desc = "harpoon quick menu" })
-- map('n', "<C-c>", function()
--   local harpoon = require("harpoon")
--   harpoon.ui:close_menu()
-- end, { desc = "harpoon close window" })
-- map('n', "<leader>1", function() require("harpoon"):list():select(1) end, { desc = "harpoon to file 1", })
-- map('n', "<leader>2", function() require("harpoon"):list():select(2) end, { desc = "harpoon to file 2", })
-- map('n', "<leader>3", function() require("harpoon"):list():select(3) end, { desc = "harpoon to file 3", })
-- map('n', "<leader>4", function() require("harpoon"):list():select(4) end, { desc = "harpoon to file 4", })
-- map('n', "<leader>5", function() require("harpoon"):list():select(5) end, { desc = "harpoon to file 5", })

-- local builtin = require("telescope.builtin")
-- -- See `:help telescope.builtin`
-- vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
-- vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
-- vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
-- vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[F]ind Telescope" })
-- vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
-- vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
-- vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })
-- vim.keymap.set("n", "<leader>fp", builtin.resume, { desc = "[F]ind Resume [P]revious" })
-- vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "[F]ind [R]ecent files" })
-- vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
-- vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" })
-- vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[F]ind existing [B]uffers" })
-- vim.keymap.set("n", "<leader>fc", builtin.colorscheme, { desc = "[F]ind [C]olorschemes" })
-- vim.keymap.set("n", "<leader>fm", builtin.marks, { desc = "[F]ind [M]arks" })
--
-- -- Slightly advanced example of overriding default behavior and theme
-- vim.keymap.set("n", "<leader>/", function()
-- 	-- You can pass additional configuration to Telescope to change the theme, layout, etc.
-- 	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
-- 		winblend = 10,
-- 		previewer = false,
-- 	}))
-- end, { desc = "[/] Fuzzily search in current buffer" })
--
-- -- It's also possible to pass additional configuration options.
-- --  See `:help telescope.builtin.live_grep()` for information about particular keys
-- vim.keymap.set("n", "<leader>f/", function()
-- 	builtin.live_grep({
-- 		grep_open_files = true,
-- 		prompt_title = "Live Grep in Open Files",
-- 	})
-- end, { desc = "[F]ind [/] in Open Files" })
--
-- -- Shortcut for searching your Neovim configuration files
-- -- vim.keymap.set("n", "<leader>sn", function()
-- -- 	builtin.find_files({ cwd = vim.fn.stdpath("config") })
-- -- end, { desc = "[F]ind [N]eovim files" })
