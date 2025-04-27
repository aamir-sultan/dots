return {
	"stevearc/conform.nvim",
	tag = "v7.1.0",
	event = { "BufReadPost" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				-- html = { "prettier" },
				-- json = { "prettier" },
				-- yaml = { "prettier" },
				-- markdown = { "prettier" },
				lua = { "stylua" },
				-- verilog = { "svls" },
				-- systemverilog = { "svls" },
				-- python = { 'black' }, -- Requires Version >= 3.9
				-- python = { 'mypy' },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
