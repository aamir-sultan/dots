local neotree_options = {
	window = {
		position = "current",
		-- position = "float",
		-- position = "right",
		-- position = "left",
		width = 40,
		-- mapping_options = {
		--   noremap = true,
		--   nowait = true,
		-- },
	},
	filesystem = {
		filtered_items = {
			visible = false, -- when true, they will just be displayed differently than normal items
			hide_dotfiles = false,
			hide_gitignored = false,
			--     hide_hidden = false,   -- only works on Windows for hidden files/directories
			--     hide_by_name = {
			--       --"node_modules"
			--     },
			--     hide_by_pattern = {   -- uses glob style patterns
			--       --"*.meta",
			--       --"*/src/*/tsconfig.json",
			--     },
			--     always_show = {   -- remains visible even if other settings would normally hide it
			--       --".gitignored",
			--     },
			--     never_show = {   -- remains hidden even if visible is toggled to true, this overrides always_show
			--       --".DS_Store",
			--       --"thumbs.db"
			--     },
			--     never_show_by_pattern = {   -- uses glob style patterns
			--       --".null-ls_*",
			--     },
		},
		follow_current_file = {
			enabled = true, -- This will find and focus the file in the active buffer every time
			--               -- the current file is changed while the tree is open.
			-- leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
		},
		-- hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
		hijack_netrw_behavior = "open_current", -- netrw disabled, opening a directory opens neo-tree
		--   -- in whatever position is specified in window.position
		--   -- "open_current",  -- netrw disabled, opening a directory opens within the
		--   -- window like netrw would, regardless of window.position
		--   -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
		--   use_libuv_file_watcher = false,   -- This will use the OS level file watchers to detect changes
		--   -- instead of relying on nvim autocmd events.
		--   window = {
		--     mappings = {
		--       ["<bs>"] = "navigate_up",
		--       ["."] = "set_root",
		--       ["H"] = "toggle_hidden",
		--       ["/"] = "fuzzy_finder",
		--       ["D"] = "fuzzy_finder_directory",
		--       ["#"] = "fuzzy_sorter",   -- fuzzy sorting using the fzy algorithm
		--       -- ["D"] = "fuzzy_sorter_directory",
		--       ["f"] = "filter_on_submit",
		--       ["<c-x>"] = "clear_filter",
		--       ["[g"] = "prev_git_modified",
		--       ["]g"] = "next_git_modified",
		--     },
		--     fuzzy_finder_mappings = {   -- define keymaps for filter popup window in fuzzy_finder_mode
		--       ["<down>"] = "move_cursor_down",
		--       ["<C-n>"] = "move_cursor_down",
		--       ["<up>"] = "move_cursor_up",
		--       ["<C-p>"] = "move_cursor_up",
		--     },
		--   },
	},
}
return {
	"nvim-neo-tree/neo-tree.nvim",
	-- v3 tags carry no "v" prefix. Tracks `main`, where releases are cut --
	-- the old `branch = "v3.x"` sat on an untagged commit 27 behind it.
	version = "3.41.0", -- 2026-05-15, latest release
	-- Shared libs pinned here; lazy merges specs by name, so bufferline.lua
	-- and lualine.lua get these revisions from their plain-string entries.
	dependencies = {
		-- Commit-pinned: newest tag (v0.1.4) is from 2023-10.
		{ "nvim-lua/plenary.nvim", commit = "74b06c6c75e4eeb3108ec01852001636d85a932b" }, -- 2026-04-10
		-- Commit-pinned: newest tag (v0.100, 2024-05) would drop two years of icons.
		{ "nvim-tree/nvim-web-devicons", commit = "2ae6958df7ced50baac5035cec0c15799eedfbf7" }, -- 2026-07-23
		{ "MunifTanjim/nui.nvim", version = "0.4.0" }, -- 2025-05-03, latest release
		-- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	-- Eager: `hijack_netrw_behavior` must be set before `nvim <dir>` is handled,
	-- and netrw is disabled in core/lazy.lua.
	lazy = false,
	---@module "neo-tree"
	---@type neotree.Config?
	-- Single definition of <leader>e (duplicates in keymaps.lua and snacks.lua
	-- were removed). `cmd` was dropped: the command is `Neotree`, not
	-- "NeoTree toggle", so it only registered a bogus lazy stub.
	keys = {
		{ "<leader>e", "<cmd>Neotree reveal toggle<CR>", desc = "Toggle Neo-tree" },
	},
	opts = neotree_options,
}
