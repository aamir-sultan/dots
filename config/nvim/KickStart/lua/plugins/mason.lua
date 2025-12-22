return {
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = true,
		-- event = "InsertEnter",
		-- event = "VeryLazy",
		event = "BufReadPost",
		opts = {
			-- list of servers for mason to install
			ensure_installed = {
				"lua_ls",
			},
		},

		dependencies = {
			{
				"williamboman/mason.nvim",
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
			"williamboman/mason.nvim",
		},
	},
}
