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
		-- Sets animation framerate
		time_interval = 17, -- milliseconds

		-- Disable smear in the current buffer if the animation is stuck for at least this amount of time.
		-- Set to nil to disable this feature.
		delay_disable = nil, -- milliseconds

		-- Amount of time the cursor has to stay still before triggering animation.
		-- Useful if the target changes and rapidly comes back to its original position.
		-- E.g. when hitting a keybinding that triggers CmdlineEnter.
		-- Increase if the cursor makes weird jumps when hitting keys.
		delay_event_to_smear = 1, -- milliseconds

		-- Delay for `vim.on_key` to avoid redundancy with vim events triggers.
		delay_after_key = 5, -- milliseconds

		-- Smear configuration ---------------------------------------------------------

		-- How fast the smear's head moves towards the target.
		-- 0: no movement, 1: instantaneous
		stiffness = 0.6,
		-- stiffness = 0.8,

		-- How fast the smear's tail moves towards the target.
		-- 0: no movement, 1: instantaneous
		trailing_stiffness = 0.4,
		-- trailing_stiffness = 0.8,

		-- Initial velocity factor in the direction opposite to the target
		anticipation = 0.2,

		-- Velocity reduction over time. O: no reduction, 1: full reduction
		damping = 0.65,
		-- damping = 0.80,

		-- Controls if middle points are closer to the head or the tail.
		-- < 1: closer to the tail, > 1: closer to the head
		trailing_exponent = 2,
	},
}
