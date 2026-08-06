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

-- NOTE: a `VimLeave` autocmd here used to run `notify-send "hello"` on every
-- exit. It was a debugging leftover (nominally a workaround for a uv_close
-- assertion on quitting a large file) and fired a desktop notification every
-- single time Neovim closed. Removed.


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
-- Commenting -- per-filetype `commentstring` overrides
-- ============================================================================
-- Commenting itself is built into Neovim (0.10+); there is no plugin:
--
--   gcc          toggle comment on the current line
--   gc{motion}   toggle comment over a motion   (e.g. gcap, gc3j)
--   gc           toggle comment on the selection (visual mode)
--
-- numToStr/Comment.nvim used to provide these and was removed: it is
-- unmaintained (last commit June 2024) and broken on Neovim >= 0.11. It asked
-- treesitter for the comment syntax via
--     local ok, parser = pcall(vim.treesitter.get_parser, buf)
-- and 0.11 changed get_parser() to RETURN nil instead of raising when there is
-- no parser. So `ok` was true, `parser` was nil, its `if not ok` fallback never
-- fired, and it then indexed nil -- swallowed by its own error handler as the
-- useless message "[Comment.nvim] nil". The effect was that gcc silently did
-- nothing in every filetype without a treesitter parser, including .tmux.conf,
-- .conf, sh, yaml and json. The built-in reads `commentstring` directly and
-- never touches treesitter, so it works everywhere.
--
-- ---------------------------------------------------------------------------
-- ADDING A FILETYPE  <-- edit the table below
-- ---------------------------------------------------------------------------
-- Neovim's bundled ftplugins already set `commentstring` correctly for almost
-- everything (checked: conf/tmux `# %s`, sh `# %s`, python `# %s`, yaml
-- `# %s`, lua `-- %s`, systemverilog `// %s`). Only add an entry when a
-- filetype is missing or wrong.
--
-- To see what a filetype currently uses, open such a file and run:
--     :set commentstring?          or     :lua print(vim.bo.commentstring)
--
-- The key is the FILETYPE (what `:set filetype?` reports), not the extension.
-- `%s` marks where the commented text goes.
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
-- Treesitter -- start highlighting when a parser is available
-- ============================================================================
-- Treesitter is built into Neovim. It bundles parsers AND queries for:
--     c  lua  markdown  markdown_inline  query  vim  vimdoc
-- and `foldexpr` is already v:lua.vim.treesitter.foldexpr() by default, so
-- treesitter folding needs no configuration. Filetypes with no parser fall
-- back to Neovim's classic regex syntax highlighting, so nothing looks plain.
--
-- There is deliberately NO parser-installer plugin. Every current one --
-- including tree-sitter-manager.nvim, the maintained successor to
-- nvim-treesitter -- lists the `tree-sitter` CLI as a mandatory requirement,
-- and no prebuilt CLI release runs on the machines this repo targets (the
-- current one needs glibc 2.39, the oldest checked needs 2.29; CentOS 7 has
-- 2.17). Building it needs a Rust toolchain. So this config sticks to the
-- parsers Neovim ships with. See "ADDING A PARSER" below if that changes.
--
-- nvim-treesitter was removed: it is archived upstream, and on this setup it
-- could never install a parser anyway -- its `main` branch shells out to the
-- `tree-sitter` CLI, which was absent, so every install failed with
--     Error during "tree-sitter build": ENOENT (cmd): 'tree-sitter'
-- and its bulk install list was dead code besides (registered on `User
-- LazyDone` from inside `config`, which only ran later on FileType, so the
-- event had already fired -- measured: 0 autocmds registered).
--
-- ---------------------------------------------------------------------------
-- ADDING A PARSER  <-- if you ever want a language beyond the bundled seven
-- ---------------------------------------------------------------------------
-- A language needs TWO things, both found on the runtimepath:
--   1. a compiled parser at  ~/.local/share/nvim/site/parser/<lang>.so
--   2. queries at            ~/.local/share/nvim/site/queries/<lang>/highlights.scm
--                            (plus optional folds.scm / injections.scm)
--
-- Once both are in place the autocmd below picks the language up
-- automatically -- no plugin and no config change needed.
--
-- Queries can be copied from:
--   https://github.com/nvim-treesitter/nvim-treesitter/tree/main/runtime/queries/<lang>
--
-- The .so needs a compiler on some machine (not necessarily this one -- a .so
-- built on any glibc-compatible box can just be copied in). With a C compiler
-- and the tree-sitter CLI available somewhere:
--     tree-sitter build -o <lang>.so /path/to/tree-sitter-<lang>
--
-- Inspect what is currently available with:
--     :lua =vim.api.nvim_get_runtime_file('parser/*.so', true)
--     :checkhealth vim.treesitter
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
