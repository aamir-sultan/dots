return {
	"nvim-treesitter/nvim-treesitter",
	lazy = true,
	event = "VeryLazy",
	-- event = "BufEnter",
	-- event = "InsertEnter",
	-- event = "BufWinEnter",
	tag = "v0.9.3",
	build = ":TSUpdate", -- Command to update parsers
	opts = {
		-- config = function()
		-- 	require("nvim-treesitter.configs").setup({
		-- Highlight options
		highlight = {
			enable = true, -- Enable syntax highlighting
			-- disable = {
			-- 	"verilog",
			-- 	"snacks_input",
			-- 	"TelescopePrompt",
			-- },
			additional_vim_regex_highlighting = false,
		},
		matchup = {
			enable = true,
		},
		-- Indent options
		indent = {
			enable = true, -- Enable indentation based on syntax trees
		},
		-- Run :TSInstallInfo or TSModuleInfo for others information
		-- Ensure specified language parsers are installed
		-- enensure_installed = ensure_installed,
		ensure_installed = {
			"c",
			"make",
			"markdown",
			"markdown_inline",
			"cpp",
			"html",
			"json",
			"lua",
			"tmux",
			"bash",
			"toml",
			"todotxt",
			"ssh_config",
			-- "verilog", -- Get hanged on the start for loading the tree-sitter. The treesitter file is 29 mb by itself.
			-- "systemverilog",
			"vim",
			"xml",
			"vimdoc",
			"yaml",
		},
		-- You can add more configurations here as needed
		-- Custom parser configurations
		-- parser_configs = {
		-- 	systemverilog = {
		-- 		install_info = {
		-- 			url = "https://github.com/gmlarumbe/tree-sitter-systemverilog", -- The specific repository
		-- 			files = { "src/parser.c" }, -- Files needed for compilation
		-- 			-- Optional: Specify a branch or commit if needed
		-- 			-- branch = "master",
		-- 		},
		-- 		filetype = "systemverilog", -- Associate with the systemverilog filetype
		-- 	},
		-- },
		-- auto_install = true,
		-- sync_install = true,
		-- 	})
		-- end,
	},
}
