return {
	"stevearc/conform.nvim",
	tag = "v9.1.0", -- 2025-08-21, latest release
	event = { "BufReadPost" },

	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
		},
		format_on_save = {
			lsp_format = "fallback",
			async = false,
			timeout_ms = 1000,
		},
	},

	-- Must be a `keys` entry: as a bare vim.keymap.set() in the spec it ran at
	-- load time and captured a global `conform` that never existed.
	keys = {
		{
			"<leader>mp",
			function()
				require("conform").format({
					lsp_format = "fallback",
					async = false,
					timeout_ms = 1000,
				})
			end,
			mode = { "n", "v" },
			desc = "For[m]at file or range with conform ([p]rettify)",
		},
	},
}
