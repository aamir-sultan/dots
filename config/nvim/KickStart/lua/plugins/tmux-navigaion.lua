return {
  'alexghergh/nvim-tmux-navigation',
  config = function()
    require('nvim-tmux-navigation').setup {
      -- Optional: configure the plugin here
      -- disable_when_zoomed = true,
      -- keybindings = { ... }
    }
  end,
}
