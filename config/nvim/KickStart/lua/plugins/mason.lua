-- NOTE: mason moved from `williamboman/*` to `mason-org/*` with v2.
-- The old paths only still resolve because GitHub 301-redirects them.
return {
	{
		"mason-org/mason-lspconfig.nvim",
		lazy = true,
		event = "BufReadPost",
		opts = {
			-- list of servers for mason to install
			ensure_installed = {
				"lua_ls",
			},
		},

		dependencies = {
			{
				"mason-org/mason.nvim",
				lazy = true,
				opts = {
					ui = {
						icons = {
							package_installed = "✓",
							package_pending = "➜",
							package_uninstalled = "✗",
						},
					},
				},
			},
			{
				"neovim/nvim-lspconfig",
				lazy = true,
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = true,
		event = "VeryLazy",
		opts = {
			ensure_installed = {
				"stylua", -- lua formatter
			},
		},
		dependencies = {
			"mason-org/mason.nvim",
		},
	},
}
