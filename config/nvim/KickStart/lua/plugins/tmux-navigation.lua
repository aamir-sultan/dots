-- Seamless <C-hjkl> movement between Neovim splits and tmux panes.
-- Pairs with `christoomey/vim-tmux-navigator` on the tmux side (.tmux.conf).
return {
	"alexghergh/nvim-tmux-navigation",
	-- No tags upstream; last upstream commit 2024-02.
	commit = "4898c98702954439233fdaf764c39636681e2861", -- 2024-02-06
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
