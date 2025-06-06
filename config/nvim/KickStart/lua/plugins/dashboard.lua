return {
	--  {
	--    "nvimdev/dashboard-nvim",
	--    -- lazy = false, -- As https://github.com/nvimdev/dashboard-nvim/pull/450, dashboard-nvim shouldn't be lazy-loaded to properly handle stdin.
	--    event = "VimEnter",
	--    dependencies = {
	--      'BlakeJC94/alpha-nvim-fortune',
	--    },
	--
	--    opts = function()
	--      local fortune = require("alpha.fortune")
	--      local qoute = fortune()
	--      -- local plug =  [[
	--      -- [  Github] [ aamir-sultan]
	--      -- ]]
	--      --       local logo = [[
	--      -- 110 118 105 109
	--      -- ]]
	--      local logo = [[
	--
	--            .__
	--  _______  _|__| _____
	-- /    \  \/ /  |/     \
	--|   |  \   /|  |  Y Y  \
	--|___|  /\_/ |__|__|_|  /
	--     \/              \/
	--
	--  ]]
	--
	--      local combined = logo .. qoute
	--      logo = combined .. "\n"
	--
	--      local opts = {
	--        -- theme = "doom", -- doom can use the buttons style which LazyLite is following
	--        theme = "hyper",
	--        max_width = 100,
	--        hide = {
	--          -- this is taken care of by lualine
	--          -- enabling this messes up the actual laststatus setting after loading a file
	--          statusline = false,
	--        },
	--        config = {
	--          shortcut = {},                 -- Require this to remove the glepnir marks
	--          header = vim.split(logo, "\n"),
	--          packages = { enable = false }, -- show how many plugins neovim loaded as the following function also do it
	--          -- mru = { limit = 10, icon = 'your icon', label = '', cwd_only = false },
	--          footer = function()
	--            local stats = require("lazy").stats()
	--            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
	--            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
	--          end,
	--        },
	--      }
	--
	--      --      for _, button in ipairs(opts.config.center) do
	--      --        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
	--      --        button.key_format = "  %s"
	--      --      end
	--
	--      -- open dashboard after closing lazy
	--      if vim.o.filetype == "lazy" then
	--        vim.api.nvim_create_autocmd("WinClosed", {
	--          pattern = tostring(vim.api.nvim_get_current_win()),
	--          once = true,
	--          callback = function()
	--            vim.schedule(function()
	--              vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
	--            end)
	--          end,
	--        })
	--      end
	--
	--      return opts
	--    end,
	--  },

	{
		"mhinz/vim-startify",
		--  lazy = true,
		-- event = "VimEnter",
	},
	--  {
	--  "rubiin/fortune.nvim",
	--   event = "VimEnter",
	--   lazy = false,
	--   opt = {
	---- max width the fortune section should take place
	--max_width = 60,
	--
	---- Controls the amount of text displayed
	---- short - One liners (default)
	---- long - Multiple lines
	---- mixed - Combination of above
	--display_format = "short",
	--
	---- The type of fortune to display
	---- quotes - Random techy quotes
	---- tips - Neovim productivity tips
	---- mixed - Combination of above
	--content_type = "quotes",
	--
	---- An optional object of custom quotes to replace the default ones like this:
	---- {
	----     short = {
	----         { "This is a short quote", "- Author" },
	----         { "This is another short quote", "- Author" },
	----     },
	----     long = {
	----         { "This is a long quote", "- Author" },
	----         { "This is another long quote", "- Author" },
	----     }
	---- }
	--custom_quotes = {},
	--
	---- An optional object of custom tips to replace the default ones like this:
	---- {
	----     short = {
	----         { "In normal mode, x will delete a single character" },
	----         { "In visual mode, x will delete a range of characters" },
	----     },
	----     long = {
	----         { "To delete from the current line to the end of the line, use d$" },
	----         { "To delete from the current line to the beginning of the line, use d^" },
	----     }
	---- }
	--custom_tips = {},
	--}
	--  },
}
