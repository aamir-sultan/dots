-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'MasonToolsStartingInstall',
--   callback = function()
--     vim.schedule(function()
--       print 'mason-tool-installer is starting'
--     end)
--   end,
-- })
--
-- vim.api.nvim_create_autocmd('User', {
--   pattern = 'MasonToolsUpdateCompleted',
--   callback = function(e)
--     vim.schedule(function()
--       print(vim.inspect(e.data)) -- print the table that lists the programs that were installed
--     end)
--   end,
-- })
--
-- Create group to assign commands
-- "clear = true" must be set to prevent loading an
-- auto-command repeatedly every time a file is resourced
local autocmd_group = vim.api.nvim_create_augroup("UserAutoCmds", { clear = true })
-- vim.api.nvim_create_autocmd({ 'BufEnter' }, {
-- command = "echo 'Welcome to LazyLite!'",
-- print("Welcome to LazyLite!")
-- callback = function()
-- print 'Welcome to LazyLite!'
-- end,
-- group = autocmd_group,
-- })

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	-- vim.api.nvim_create_autocmd({ "BufReadPre" }, {
	desc = "Auto Install listed Mason tools",
	callback = function()
		vim.cmd(":MasonToolsInstallSync")
		-- print("Executed the MasonToolsInstallSync")
	end,
	group = autocmd_group,
})

-- Find what filetype this current buffer is
-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
-- 	callback = function()
-- 		vim.cmd(":set filetype?")
-- 	end,
-- 	group = autocmd_group,
-- })

-- " I can't remember a time when I didn't want to save a file after tabbing away from my editor (especially with version control and Vim's persistent undo):
vim.api.nvim_create_autocmd({ "FocusLost" }, {
	desc = "Save on focus lost aka autosave",
	callback = function()
		vim.cmd(":wa")
	end,
	group = autocmd_group,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
	group = autocmd_group,
})
