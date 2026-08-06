-- mason moved from williamboman/* to mason-org/* at v2; the old paths only
-- resolve via GitHub's 301 redirect.
return {
	{
		"mason-org/mason-lspconfig.nvim",
		version = "v2.3.0", -- 2026-06-11, latest release
		lazy = true,
		event = "BufReadPost",
		opts = {
			-- list of servers for mason to install
			ensure_installed = {
				"lua_ls",
				"verible",
			},
		},

		dependencies = {
			{
				"mason-org/mason.nvim",
				version = "v2.3.1", -- 2026-06-11, latest release
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
		-- No tags upstream.
		commit = "443f1ef8b5e6bf47045cb2217b6f748a223cf7dc", -- 2026-01-22
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
