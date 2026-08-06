return {
	"stevearc/conform.nvim",
	tag = "v9.1.0",
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

	-- NOTE: this must be a `keys` entry, not a bare `vim.keymap.set(...)` in the
	-- spec table. As a bare call it ran at spec-load time and captured a global
	-- `conform` that never existed, so the mapping always errored.
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
