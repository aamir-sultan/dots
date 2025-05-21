return {
	"sphamba/smear-cursor.nvim",
	-- lazy = true,
	-- event = "VeryLazy",
	-- event = 'BufEnter',
	event = "UIEnter",
	-- event = "WinEnter",
	-- ft = "*",
	-- cond = vim.g.neovide == nil,
	-- opts = {
	--   hide_target_hack = true,
	--   cursor_color = "none",
	-- },
	-- specs = {
	--   -- disable mini.animate cursor
	--   {
	--     "echasnovski/mini.animate",
	--     optional = true,
	--     opts = {
	--       cursor = { enable = false },
	--     },
	--   },
	-- },
	opts = {
		cursor_color = "#D66924",
	},
}
