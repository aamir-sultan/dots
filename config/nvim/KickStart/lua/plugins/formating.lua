return {
	"stevearc/conform.nvim",
	tag = "v9.1.0",
	event = { "BufReadPost" },

	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
		},
		format_on_save = {
			lsp_fallback = true,
			async = false,
			timeout_ms = 1000,
		},
	},

	vim.keymap.set({ "n", "v" }, "<leader>mp", function()
		conform.format({
			lsp_fallback = true,
			async = false,
			timeout_ms = 1000,
		})
	end, { desc = "Format file or range (in visual mode)" }),
}
