-- Seamless <C-hjkl> movement between Neovim splits and tmux panes.
-- Pairs with `christoomey/vim-tmux-navigator` on the tmux side (see .tmux.conf).
--
-- These keys used to be set in config/keymaps.lua via a top-level
-- `require("nvim-tmux-navigation")`, which defeated lazy loading and silently
-- overwrote the plain <C-w> window maps defined earlier in that same file.
return {
	"alexghergh/nvim-tmux-navigation",
	opts = {
		-- disable_when_zoomed = true,
	},
	keys = {
		{
			"<C-h>",
			function()
				require("nvim-tmux-navigation").NvimTmuxNavigateLeft()
			end,
			desc = "Navigate left (nvim/tmux)",
		},
		{
			"<C-j>",
			function()
				require("nvim-tmux-navigation").NvimTmuxNavigateDown()
			end,
			desc = "Navigate down (nvim/tmux)",
		},
		{
			"<C-k>",
			function()
				require("nvim-tmux-navigation").NvimTmuxNavigateUp()
			end,
			desc = "Navigate up (nvim/tmux)",
		},
		{
			"<C-l>",
			function()
				require("nvim-tmux-navigation").NvimTmuxNavigateRight()
			end,
			desc = "Navigate right (nvim/tmux)",
		},
		{
			"<C-\\>",
			function()
				require("nvim-tmux-navigation").NvimTmuxNavigateLastActive()
			end,
			desc = "Navigate to last active (nvim/tmux)",
		},
	},
}
