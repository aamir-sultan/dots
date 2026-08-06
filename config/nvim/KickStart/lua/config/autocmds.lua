-- Create group to assign commands
-- "clear = true" must be set to prevent loading an
-- auto-command repeatedly every time a file is resourced
-- local autocmd_group = vim.api.nvim_create_augroup("UserAutoCmds", { clear = true })

-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
-- command = "echo 'Welcome to LazyLite!'",
-- print("Welcome to LazyLite!")
-- callback = function()
-- print 'Welcome to LazyLite!'
-- end,
-- 	group = autocmd_group,
-- })

-- Check for external file changes (works with Claude Code)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Resize neovim split when terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("wincmd =")
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Enable spell checking for certain file types
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.txt", "*.md", "*.tex" },
  callback = function()
    vim.opt.spell = true
    vim.opt.spelllang = "en"
  end,
})

-- show cursor line only in active window
local cursorGrp = vim.api.nvim_create_augroup("CursorLine", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  pattern = "*",
  command = "set cursorline",
  group = cursorGrp,
})
vim.api.nvim_create_autocmd(
  { "InsertEnter", "WinLeave" },
  { pattern = "*", command = "set nocursorline", group = cursorGrp }
)

-- go to last loc when opening a buffer
-- this mean that when you open a file, you will be at the last position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Find what filetype this current buffer is
-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
--   callback = function()
--     vim.cmd(":set filetype?")
--   end,
--   group = autocmd_group,
-- })

-- I can't remember a time when I didn't want to save a file after tabbing away from my editor (especially with version control and Vim's persistent undo):
-- Currently it is having issues when a buffer is open with no name and focus is lost
-- vim.api.nvim_create_autocmd({ "FocusLost" }, {
--   desc = "Save on focus lost aka autosave",
--   callback = function()
--     vim.cmd(":wa")
--   end,
--   group = autocmd_group,
-- })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
})

-- don't auto comment new line
vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

-- local function toggle_plugins()
-- 	local filepath = vim.api.nvim_buf_get_name(0)
-- 	local filetype = vim.bo.filetype
--
-- 	-- 1. Check File Size (e.g., disable if larger than 1MB)
-- 	local max_filesize = 1024 * 1024 -- 1MB in bytes
-- 	local ok, stats = pcall(vim.uv.fs_stat, filepath)
-- 	local is_big = ok and stats and stats.size > max_filesize
--
-- 	-- 2. Check File Type (add any types you want to ignore)
-- 	local excluded_filetypes = { "bigfile", "log", "csv", "json" }
-- 	local is_excluded_type = vim.tbl_contains(excluded_filetypes, filetype)
--
-- 	local smear = require("smear_cursor")
-- 	-- Toggle based on conditions
-- 	if is_big or is_excluded_type then
-- 		smear.enabled = false
-- 	else
-- 		smear.enabled = true
-- 	end
-- end
--
-- -- Run every time you enter a buffer
-- vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
-- 	pattern = "*",
-- 	callback = function()
-- 		-- Use pcall to prevent errors if the plugin isn't loaded yet
-- 		pcall(toggle_plugins)
-- 	end,
-- })

-- Create an augroup so autocmds don't stack when the config is reloaded
local numbertoggle = vim.api.nvim_create_augroup("numbertoggle", { clear = true })

-- Enable relative numbering when entering a buffer or leaving insert mode
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = numbertoggle,
  callback = function()
    if vim.opt.number:get() and vim.api.nvim_get_mode().mode ~= "i" then
      vim.opt.relativenumber = true
    end
  end,
})

-- Disable relative numbering when leaving a buffer or entering insert mode
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = numbertoggle,
  callback = function()
    if vim.opt.number:get() then
      vim.opt.relativenumber = false
    end
  end,
})


-- ============================================================================
-- Commenting: per-filetype `commentstring` overrides
-- ============================================================================
-- Commenting is built into Neovim (0.10+), no plugin: gcc (line),
-- gc{motion}, gc (visual). It reads `commentstring`, so it works in every
-- filetype -- unlike Comment.nvim, which broke on nvim 0.11 in any filetype
-- without a treesitter parser (.tmux.conf, sh, yaml, ...).
--
-- Neovim's ftplugins already set `commentstring` correctly almost everywhere,
-- so only add an entry when one is missing or wrong. Key is the FILETYPE
-- (`:set filetype?`), not the extension; `%s` is where the text goes.
-- Check the current value with `:set commentstring?`.
local commentstrings = {
	-- Strict JSON has no comment syntax, so Neovim leaves commentstring empty.
	-- Uncomment if you edit JSON-with-comments (jsonc, tsconfig, ...).
	-- ["json"] = "// %s",

	-- Template -- both are already correct by default, shown only as examples:
	-- ["systemverilog"] = "// %s",
	-- ["verilog"] = "// %s",
}

if next(commentstrings) ~= nil then
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("user_commentstring", { clear = true }),
		pattern = vim.tbl_keys(commentstrings),
		desc = "Apply commentstring overrides",
		callback = function(event)
			local cs = commentstrings[event.match]
			if cs then
				vim.bo[event.buf].commentstring = cs
			end
		end,
	})
end

-- ============================================================================
-- Treesitter: start highlighting when a parser is available
-- ============================================================================
-- Neovim bundles parsers and queries for c, lua, markdown, markdown_inline,
-- query, vim and vimdoc, and sets a treesitter `foldexpr` by default.
-- Filetypes without a parser fall back to regex syntax highlighting.
--
-- There is no parser-installer plugin on purpose: nvim-treesitter is archived,
-- and every replacement (incl. tree-sitter-manager.nvim) requires the
-- `tree-sitter` CLI, which has no prebuilt release that runs on CentOS 7
-- (needs glibc >= 2.29; CentOS 7 has 2.17).
--
-- To add a language, drop both on the runtimepath -- the autocmd below then
-- picks it up with no config change:
--   ~/.local/share/nvim/site/parser/<lang>.so
--   ~/.local/share/nvim/site/queries/<lang>/highlights.scm
-- Queries: github.com/nvim-treesitter/nvim-treesitter/tree/main/runtime/queries
-- Inspect with `:checkhealth vim.treesitter`.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
	desc = "Enable treesitter highlighting when a parser is available",
	callback = function(event)
		local lang = vim.treesitter.language.get_lang(event.match) or event.match

		-- Only proceed when a parser for this language actually exists, so the
		-- many filetypes without one never produce an error.
		local ok, has_parser = pcall(vim.treesitter.language.add, lang)
		if not ok or not has_parser then
			return
		end

		pcall(vim.treesitter.start, event.buf, lang)
	end,
})
