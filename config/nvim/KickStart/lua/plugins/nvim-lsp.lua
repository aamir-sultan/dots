return {
	"neovim/nvim-lspconfig",
	version = "v2.11.0", -- 2026-07-21, latest release
	event = "VeryLazy",
	dependencies = { "saghen/blink.cmp" },

	-- example using `opts` for defining servers
	opts = {
		-- servers = {
		-- 	lua_ls = {},
		-- },
	},
	-- example calling setup directly for each LSP
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		vim.lsp.config("*", { capabilities = capabilities })
	end,
}
