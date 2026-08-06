-- ~/.wezterm.lua
--
-- Single-file WezTerm configuration.
--
-- Layout of this file:
--   1. Helpers
--   2. Palette
--   3. Font / appearance constants
--   4. Renderer selection
--   5. Keybinds, key tables, mouse bindings
--   6. Event handlers (tab bar, status line, custom events)
--   7. Config assembly
--
-- A note on SHIFT: for printable keys WezTerm matches the *shifted* character,
-- so write `key = "Z"` rather than `key = "z", mods = "SHIFT"`, and `key = "~"`
-- rather than `key = "`", mods = "SHIFT"`.
--
-- A note on events: register `format-tab-title` EXACTLY ONCE. WezTerm calls
-- every registered handler and uses the first non-nil return, so a second one
-- silently wins and the other becomes dead code.

local wezterm = require("wezterm")
local act = wezterm.action

-- config_builder gives much better error messages than a bare table
local config = wezterm.config_builder and wezterm.config_builder() or {}

---------------------------------------------------------------
--- 1. Helpers
---------------------------------------------------------------
-- Dropped from the previous version because nothing ever called them:
-- exists(), convert_home_dir(), convert_useful_path(), split_from_url(),
-- getRandomStringFromTable(), getRandomBackgroundPath(), get_files_in_dir(),
-- is_valid_image_file(), test(), and handle_key_binding() -- the last of which
-- referenced an undefined global `leader` and would have errored on first call.

--- "/usr/bin/nvim" -> "nvim" ; "C:\\...\\nvim.exe" -> "nvim"
local function basename(path)
  local s = (path or ""):gsub("%.exe$", "")
  return s:match("([^/\\]+)$") or s
end

--- Concatenate two array-like tables into a new one.
--- Later entries win in WezTerm's key lookup, so pass defaults first.
local function merge_lists(t1, t2)
  local result = {}
  for _, v in ipairs(t1 or {}) do
    table.insert(result, v)
  end
  for _, v in ipairs(t2 or {}) do
    table.insert(result, v)
  end
  return result
end

--- Merge two `key_tables` maps (name -> list of keybinds), concatenating each
--- named list so our entries override the upstream defaults while any new
--- upstream bindings we haven't overridden keep working.
--- Note: a recursive map-merge would be wrong here -- it would pair element 1
--- with element 1, element 2 with element 2, and produce nonsense.
local function merge_key_tables(defaults, ours)
  local result = {}
  for name, binds in pairs(defaults or {}) do
    result[name] = merge_lists(binds, {})
  end
  for name, binds in pairs(ours or {}) do
    result[name] = merge_lists(result[name], binds)
  end
  return result
end

--- Only enable Wayland on an actual Wayland session. No effect on Windows/macOS.
local function enable_wayland()
  if os.getenv("DESKTOP_SESSION") == "hyprland" then
    return true
  end
  if os.getenv("XDG_SESSION_TYPE") == "wayland" then
    return true
  end
  return false
end

--- Pick a random image from a directory.
--- Replaces the old io.popen('ls ...') version, which shelled out on every
--- config reload and didn't work on Windows. wezterm.glob is native. Returns
--- nil rather than erroring when the directory is missing or empty, so it's
--- safe to use directly in a config value.
local IMAGE_EXTS = { jpg = true, jpeg = true, png = true, bmp = true, gif = true, webp = true }

local function random_image(dir)
  local ok, entries = pcall(wezterm.glob, dir .. "/*")
  if not ok or type(entries) ~= "table" then
    return nil
  end

  local images = {}
  for _, path in ipairs(entries) do
    local ext = path:lower():match("%.(%w+)$")
    if ext and IMAGE_EXTS[ext] then
      table.insert(images, path)
    end
  end

  if #images == 0 then
    return nil
  end
  return images[math.random(#images)]
end

local function is_windows()
  return wezterm.target_triple:find("windows") ~= nil
end

---------------------------------------------------------------
--- 2. Palette
---------------------------------------------------------------
-- One place for colours, so the tab bar and config.colors can't drift apart.
-- The previous version set colors.tab_bar.active_tab to orange while the
-- format-tab-title handler hardcoded Catppuccin purple.

local palette = {
  -- Tab bar
  bar_bg = "#1e1e2e",        -- strip beyond the last tab; kept in sync with tab edges

  tab_active_bg = "#F59C4F", -- Mustard-Orange
  tab_active_fg = "#073642",
  -- tab_active_bg = "#2AA198", -- Solarized teal
  -- tab_active_bg = "#cba6f7", -- Catppuccin mauve

  tab_inactive_bg = "#313244",
  tab_inactive_fg = "#a6adc8",
  tab_hover_bg = "#45475a",
  tab_hover_fg = "#cdd6f4",

  tab_new_fg = "#6c7086",
  alert = "#f9e2af", -- unseen-output marker

  -- Cursor
  cursor_bg = "#D66924", -- Mustard-Dark
  cursor_fg = "#343235", -- Black+Brown
  -- cursor_bg = "#D5C4A1", -- Yellowish
  -- cursor_bg = "#00ccff", -- Cyan
  -- cursor_bg = "#0099cc", -- Cyan Darkish
  -- cursor_bg = "#ccff00", -- Green light
  -- cursor_bg = "#ffcc00", -- Mustard
  -- cursor_bg = "#FBC02D", -- Mustard
  -- cursor_bg = "#FF5733", -- Orange
  -- cursor_fg = "#1E3435", -- Black+Brown
}

---------------------------------------------------------------
--- 3. Colour scheme
---------------------------------------------------------------
-- NOTE: every color_scheme line was commented out before, so you have been
-- running on WezTerm's built-in default palette. Uncomment one to pick a theme.

-- local color_scheme = "AdventureTime"
-- local color_scheme = "Ayu Dark"
-- local color_scheme = "ayu"
-- local color_scheme = "ayu Light"
-- local color_scheme = "Batman"
-- local color_scheme = "Catppuccin Mocha"
-- local color_scheme = "Catppuccin Latte"
-- local color_scheme = "ENCOM"
-- local color_scheme = "Gogh (Gogh)"
-- local color_scheme = "Google (dark) (terminal.sexy)"
-- local color_scheme = "Google Dark (base16)"
-- local color_scheme = "Google Dark (Gogh)"
-- local color_scheme = "Gruvbox (Gogh)"
-- local color_scheme = "Gruvbox Dark (Gogh)"
-- local color_scheme = "Gruvbox dark, hard (base16)"
-- local color_scheme = "Gruvbox dark, medium (base16)"
-- local color_scheme = "Gruvbox dark, pale (base16)"
-- local color_scheme = "Gruvbox dark, soft (base16)"
-- local color_scheme = "Gruvbox light, hard (base16)"
-- local color_scheme = "Gruvbox light, medium (base16)"
-- local color_scheme = "Gruvbox light, soft (base16)"
-- local color_scheme = "Gruvbox Material (Gogh)"
-- local color_scheme = "GruvboxDark"
-- local color_scheme = "GruvboxDarkHard"
-- local color_scheme = "GruvboxLight"
-- local color_scheme = "nordfox"
-- local color_scheme = "Dayfox"
-- local color_scheme = "Hardcore"
-- local color_scheme = "Seti"
-- local color_scheme = "Solarized"
local color_scheme = nil -- No color theme

-- Follow the OS light/dark preference instead of a fixed scheme.
-- Uncomment both blocks to use; overrides the choice above.
-- local function scheme_for_appearance()
--   if wezterm.gui and wezterm.gui.get_appearance():find("Dark") then
--     return "Gruvbox dark, hard (base16)"
--   end
--   return "Gruvbox light, hard (base16)"
-- end
-- color_scheme = scheme_for_appearance()

---------------------------------------------------------------
--- 4. Font
---------------------------------------------------------------
-- local font_size = 8.0
-- local font_size = 9.0
-- local font_size = 10.0
local font_size = 11.0
-- local font_size = 12.0

-- local font_style = "Italic"
local font_style = "Normal"

-- local font_weight = "Light"
local font_weight = "Regular"
-- local font_weight = "Medium"
-- local font_weight = "Bold"

-- local font_family = "DM Mono"
-- local font_family = "Fantasque Sans Mono"
-- local font_family = "Fira Code"
local font_family = "Iosvmata"
-- local font_family = "MesloLGS Nerd Font Mono"
-- local font_family = "MesloLGM Nerd Font Mono"
-- local font_family = "JetBrains Mono"
-- local font_family = "JuliaMono"
-- local font_family = "Maple Mono"
-- local font_family = "MartianMono NFM"
-- local font_family = "Monaspace Argon"
-- local font_family = "Monaspace Krypton"
-- local font_family = "Monaspace Neon"
-- local font_family = "Monaspace Radon"
-- local font_family = "Monaspace Xenon"
-- local font_family = "Rec Mono Casual"
-- local font_family = "Rec Mono Duotone"
-- local font_family = "Rec Mono Linear"
-- local font_family = "Rec Mono Semicasual"
-- local font_family = "UbuntuSansMono NF"
-- local font_family = "mononoki"

local font = wezterm.font_with_fallback({
  {
    family = font_family,
    weight = font_weight,
    style = font_style,
    harfbuzz_features = {
      "calt=1",
      "clig=1",
      "liga=1",
      -- "dlig",
      -- "ss01",
      -- "ss02",
      -- "ss03",
      -- "ss04",
      -- "ss05",
      -- "ss06",
      -- "ss07",
      -- "ss08",
    },
  },
  { family = "Terminus", weight = font_weight },
  -- FIX: added so the tab-bar Nerd Font icons don't silently render as tofu if
  -- the primary family is ever swapped for an unpatched one. Harmless if unused.
  "Symbols Nerd Font Mono",
  "Noto Color Emoji",
})

---------------------------------------------------------------
--- 5. Background
---------------------------------------------------------------
local hsb_dimmer = { -- FIX: was a global
  brightness = 0.3,  -- darken the background image to ~1/3
  -- brightness = 1.0,
  hue = 1.0,
  saturation = 1.0,
}

local wallpaper = "D://Resources//System//Wallpapers//YellowLeaf.jpg"
-- local wallpaper = "D://Resources//System//Wallpapers//simple//Santa_Monica.png"
-- local wallpaper = "D://Resources//System//Wallpapers//lineart//samurai.png"
-- local wallpaper = "D://Resources//System//Wallpapers//lineart//handreach.png"
-- local wallpaper = "D://Resources//System//Wallpapers//lineart//toothless.png"
-- local wallpaper = "D://Resources//System//Wallpapers//lineart//peek.png"
-- local wallpaper = "D://Resources//System//Wallpapers//lineart//gaze.png"
-- local wallpaper = "D://Resources//System//Wallpapers//lineart//fullface.png"
-- local wallpaper = "D://Resources//System//Wallpapers//lineart//halfface.png"
-- local wallpaper = "D://Resources//System//Wallpapers//road.jpg"
-- local wallpaper = "D://Resources//System//Wallpapers//leather.jpg"
-- local wallpaper = "D://Resources//System//Wallpapers//celestial//blackhole.png"

-- Random wallpaper per launch. Safe if the directory is missing or empty.
-- wallpaper = random_image("D:/Mega/backgrounds") or wallpaper
-- wallpaper = random_image("D:/Mega/backgrounds/simple") or wallpaper

local background = {
  -- Deepest / back-most layer, rendered first.
  {
    source = { File = wallpaper },

    -- "Contain" scales to fit without cropping; "Cover" fills and may crop.
    -- width = "Contain",
    height = "Contain",

    -- Other repeat options: Mirror, Repeat, NoRepeat.
    repeat_x = "NoRepeat",
    repeat_y = "NoRepeat",
    -- repeat_x = "Mirror",
    -- repeat_y = "Mirror",

    -- horizontal_align: "Left" (default), "Center", "Right"
    horizontal_align = "Right",
    -- vertical_align: "Top" (default), "Middle", "Bottom"
    vertical_align = "Top",

    -- Offsets accept '123px', '%', 'pt' or 'cell'
    -- horizontal_offset = "0px",
    -- vertical_offset = "0px",

    hsb = hsb_dimmer,
    -- opacity = 0.98,

    -- Parallax makes the layer look further behind the text when scrolling.
    -- attachment = { Parallax = 0.1 },
    attachment = "Fixed",
    -- attachment = "Scroll",
  },
}

-- Gradient background instead of an image. `background` above and
-- window_background_gradient are alternatives, so comment out config.background
-- in the assembly section if you enable this.
-- local window_background_gradient = {
--   -- "Vertical" | "Horizontal" | { Linear = { angle = n } } | Radial
--   -- orientation = "Vertical",
--   orientation = { Linear = { angle = -45.0 } },
--
--   -- colors = { "#0f0c29", "#302b63", "#24243e" },
--   -- colors = { "#DCDAD6" }, -- Smoke
--   -- colors = { "#FFFFFF" }, -- White
--   -- colors = { "#FFFEF0" }, -- OffWhite
--   -- colors = { "#FDF6E3" }, -- OffWhite
--   -- colors = { "#000000" }, -- Black
--   -- colors = { "#00141a" }, -- Solarized Osaka background
--   -- colors = { "#161b1d" }, -- Solarized Osaka background
--   -- colors = { "#300924" }, -- Ubuntu terminal
--   -- colors = { "#EEE8D5" }, -- Solarized background
--   -- colors = { "#073642" }, -- Solarized background
--   -- colors = { "#300924", "#2E3436" },
--   -- colors = { "#fdf6e3" },
--   -- colors = { "#dfca88" },
--   -- colors = { "#3C3836" },
--
--   -- preset = "Warm", -- instead of `colors`
--
--   interpolation = "Linear", -- "Linear" | "Basis" | "CatmullRom"
--   blend = "Rgb",            -- "Rgb" | "LinearRgb" | "Hsv" | "Oklab"
--   -- noise = 64,            -- anti-banding jitter; 0 makes bands obvious
--   -- segment_size = 11,
--   -- segment_smoothness = 0.0,
-- }

---------------------------------------------------------------
--- 6. Renderer
---------------------------------------------------------------
-- FIX: the previous version called wezterm.gui.enumerate_gpus() at the top
-- level, unguarded. `wezterm.gui` is nil when the config is loaded by the mux
-- server or by `wezterm cli`, so that line raised an error in those contexts.
-- It also set webgpu_preferred_adapter while front_end was "OpenGL", where it
-- is ignored. Both are now guarded and consistent.
local function apply_renderer(cfg)
  cfg.front_end = "OpenGL" -- "WebGpu" | "OpenGL" | "Software"
  cfg.max_fps = 60

  if not wezterm.gui then
    return
  end

  local ok, gpus = pcall(wezterm.gui.enumerate_gpus)
  if not ok or type(gpus) ~= "table" then
    return
  end

  for _, gpu in ipairs(gpus) do
    if gpu.backend == "Vulkan" and gpu.device_type == "DiscreteGpu" then
      cfg.front_end = "WebGpu"
      cfg.webgpu_preferred_adapter = gpu
      cfg.webgpu_power_preference = "HighPerformance"
      return
    end
  end

  for _, gpu in ipairs(gpus) do
    if gpu.backend == "Vulkan" and gpu.device_type == "IntegratedGpu" then
      cfg.front_end = "WebGpu"
      cfg.webgpu_preferred_adapter = gpu
      return
    end
  end
end

---------------------------------------------------------------
--- 7. Keybinds
---------------------------------------------------------------
-- Scheme: LEADER (ALT+a) for tmux-like actions, ALT+SHIFT for direct tab
-- movement, CTRL+SHIFT for direct pane movement.

local default_keybinds = {
  { key = "j",        mods = "LEADER",     action = act.ShowLauncher },
  { key = "a",        mods = "LEADER",     action = act.ShowLauncher },
  { key = "a",        mods = "LEADER|ALT", action = act.ShowLauncher },

  { key = "c",        mods = "CTRL|SHIFT", action = act({ CopyTo = "Clipboard" }) },
  { key = "v",        mods = "CTRL|SHIFT", action = act({ PasteFrom = "Clipboard" }) },
  -- { key = "y", mods = "LEADER", action = act({ CopyTo = "Clipboard" }) },
  -- { key = "p", mods = "LEADER", action = act({ PasteFrom = "Clipboard" }) }, -- conflicts with PaneSelect
  { key = "Insert",   mods = "LEADER",     action = act({ PasteFrom = "PrimarySelection" }) },

  { key = "t",        mods = "LEADER",     action = act.SpawnTab("CurrentPaneDomain") }, -- CTRL+t is fzf
  { key = "c",        mods = "LEADER",     action = act.SpawnTab("CurrentPaneDomain") },
  { key = "x",        mods = "LEADER",     action = act({ CloseCurrentPane = { confirm = true } }) },

  { key = "P",        mods = "LEADER",     action = act.ActivateCommandPalette },
  { key = "d",        mods = "LEADER",     action = act.ShowDebugOverlay },
  { key = "Space",    mods = "LEADER",     action = act.ShowTabNavigator },

  { key = "=",        mods = "LEADER",     action = act.ResetFontSize },
  { key = "]",        mods = "LEADER",     action = act.IncreaseFontSize },
  { key = "[",        mods = "LEADER",     action = act.DecreaseFontSize },

  { key = "PageUp",   mods = "LEADER",     action = act({ ScrollByPage = -1 }) },
  { key = "PageDown", mods = "LEADER",     action = act({ ScrollByPage = 1 }) },
  { key = "b",        mods = "LEADER",     action = act({ ScrollByPage = -1 }) },
  { key = "f",        mods = "LEADER",     action = act({ ScrollByPage = 1 }) },

  -- FIX: copy mode was unreachable. disable_default_key_bindings is true and
  -- the only ActivateCopyMode binding was commented out, so the ~130-line
  -- copy_mode key table below could only be reached via LEADER+/ then Enter.
  { key = "k",        mods = "LEADER",     action = act.ActivateCopyMode },

  -- CHANGED: ReloadConfiguration moved from LEADER+z to LEADER+R so that
  -- LEADER+z can be pane zoom (the tmux default, and the one binding this
  -- config was missing entirely). Manual reload is close to redundant anyway
  -- since automatically_reload_config is true. Swap the two back if you'd
  -- rather keep the muscle memory.
  { key = "R",        mods = "LEADER",     action = act.ReloadConfiguration },
  -- FIX: was `key = "z", mods = "LEADER|SHIFT"`, which never matched.
  { key = "Z",        mods = "LEADER",     action = act({ EmitEvent = "toggle-tmux-keybinds" }) },
  { key = "e",        mods = "LEADER",     action = act({ EmitEvent = "trigger-nvim-with-scrollback" }) },

  { key = "p",        mods = "LEADER",     action = act.PaneSelect({ alphabet = "1234567890" }) },
  -- Swap the selected pane with the active one instead of just focusing it:
  -- { key = "P", mods = "LEADER", action = act.PaneSelect({ mode = "SwapWithActive" }) },
  { key = "`",        mods = "LEADER",     action = act.RotatePanes("Clockwise") },
  -- FIX: was `key = "`", mods = "LEADER|SHIFT"`, which never matched.
  { key = "~",        mods = "LEADER",     action = act.RotatePanes("CounterClockwise") },

  {
    key = "r",
    mods = "LEADER",
    action = act({
      ActivateKeyTable = {
        name = "resize_pane",
        one_shot = false,
        timeout_milliseconds = 3000,
        replace_current = false,
      },
    }),
  },

  -- FIX: the `leader` key table used to be defined but unreachable (its
  -- activator was commented out). Renamed to `nav` -- calling a key table
  -- "leader" is confusing next to config.leader -- and bound here.
  {
    key = "n",
    mods = "LEADER",
    action = act({
      ActivateKeyTable = {
        name = "nav",
        one_shot = false,
        timeout_milliseconds = 3000,
        replace_current = false,
      },
    }),
  },

  {
    key = "E",
    mods = "LEADER",
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        -- line is nil on Escape, "" on a bare Enter
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },

  -- Workspaces (new). These are WezTerm's equivalent of tmux sessions.
  -- LEADER+w is already the tab navigator here, so the fuzzy switcher is on g.
  { key = "g", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
  {
    key = "N",
    mods = "LEADER",
    action = act.PromptInputLine({
      description = "Enter name for new workspace",
      action = wezterm.action_callback(function(window, pane, line)
        if line and #line > 0 then
          window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
        end
      end),
    }),
  },
  -- Rename the current workspace:
  -- {
  --   key = "$",
  --   mods = "LEADER",
  --   action = act.PromptInputLine({
  --     description = "Rename workspace",
  --     action = wezterm.action_callback(function(window, pane, line)
  --       if line and #line > 0 then
  --         wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
  --       end
  --     end),
  --   }),
  -- },
}

-- Idea: ALT+SHIFT for WezTerm, ALT inside tmux, with some exceptions.
-- These are the bindings LEADER+Z toggles off.
local tmux_keybinds = {
  -- { key = "j", mods = "ALT", action = act({ SpawnTab = "CurrentPaneDomain" }) }, -- conflicts with Neovim line-move
  -- { key = "k", mods = "ALT", action = act({ CloseCurrentTab = { confirm = true } }) }, -- k for kill
  -- { key = "h",          mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = -1 }) },
  -- { key = "l",          mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = 1 }) },
  -- { key = "LeftArrow",  mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = -1 }) },
  -- { key = "RightArrow", mods = "CTRL|SHIFT", action = act({ ActivateTabRelative = 1 }) },

  -- Tab movement
  { key = "h",          mods = "ALT|SHIFT",      action = act({ ActivateTabRelative = -1 }) },
  { key = "l",          mods = "ALT|SHIFT",      action = act({ ActivateTabRelative = 1 }) },
  { key = "LeftArrow",  mods = "ALT|SHIFT",      action = act({ ActivateTabRelative = -1 }) },
  { key = "RightArrow", mods = "ALT|SHIFT",      action = act({ ActivateTabRelative = 1 }) },
  { key = "h",          mods = "LEADER",         action = act({ ActivateTabRelative = -1 }) },
  { key = "l",          mods = "LEADER",         action = act({ ActivateTabRelative = 1 }) },
  -- { key = "LeftArrow",  mods = "LEADER", action = act({ ActivateTabRelative = -1 }) },
  -- { key = "RightArrow", mods = "LEADER", action = act({ ActivateTabRelative = 1 }) },
  -- Reorder tabs:
  -- { key = "h", mods = "ALT|CTRL", action = act({ MoveTabRelative = -1 }) },
  -- { key = "l", mods = "ALT|CTRL", action = act({ MoveTabRelative = 1 }) },
  -- { key = "k", mods = "ALT|CTRL", action = act.ActivateCopyMode },
  -- {
  --   key = "k",
  --   mods = "ALT|CTRL",
  --   action = act.Multiple({ act.CopyMode("ClearSelectionMode"), act.ActivateCopyMode, act.ClearSelection }),
  -- },
  -- { key = "j", mods = "ALT|CTRL", action = act({ PasteFrom = "PrimarySelection" }) },

  -- Jump straight to a tab
  { key = "1",          mods = "LEADER",         action = act({ ActivateTab = 0 }) },
  { key = "2",          mods = "LEADER",         action = act({ ActivateTab = 1 }) },
  { key = "3",          mods = "LEADER",         action = act({ ActivateTab = 2 }) },
  { key = "4",          mods = "LEADER",         action = act({ ActivateTab = 3 }) },
  { key = "5",          mods = "LEADER",         action = act({ ActivateTab = 4 }) },
  { key = "6",          mods = "LEADER",         action = act({ ActivateTab = 5 }) },
  { key = "7",          mods = "LEADER",         action = act({ ActivateTab = 6 }) },
  { key = "8",          mods = "LEADER",         action = act({ ActivateTab = 7 }) },
  { key = "9",          mods = "LEADER",         action = act({ ActivateTab = 8 }) },

  -- Splits
  { key = "s",          mods = "LEADER",         action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
  { key = "v",          mods = "LEADER",         action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },

  -- Pane focus
  { key = "h",          mods = "CTRL|SHIFT",     action = act({ ActivatePaneDirection = "Left" }) },
  { key = "l",          mods = "CTRL|SHIFT",     action = act({ ActivatePaneDirection = "Right" }) },
  { key = "k",          mods = "CTRL|SHIFT",     action = act({ ActivatePaneDirection = "Up" }) },
  { key = "j",          mods = "CTRL|SHIFT",     action = act({ ActivatePaneDirection = "Down" }) },

  -- Pane resize. NOTE: these only work because treat_left_ctrlalt_as_altgr is
  -- now false (see the assembly section); with it true, left-Ctrl+Alt is
  -- reported as AltGr and these never fire.
  { key = "h",          mods = "ALT|CTRL|SHIFT", action = act({ AdjustPaneSize = { "Left", 1 } }) },
  { key = "l",          mods = "ALT|CTRL|SHIFT", action = act({ AdjustPaneSize = { "Right", 1 } }) },
  { key = "k",          mods = "ALT|CTRL|SHIFT", action = act({ AdjustPaneSize = { "Up", 1 } }) },
  { key = "j",          mods = "ALT|CTRL|SHIFT", action = act({ AdjustPaneSize = { "Down", 1 } }) },

  -- NEW: pane zoom. The previous config had no zoom binding at all.
  { key = "z",          mods = "LEADER",         action = act.TogglePaneZoomState },
  { key = "Enter",      mods = "LEADER",         action = act.QuickSelect },
  { key = "/",          mods = "LEADER",         action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "m",          mods = "LEADER",         action = act.ToggleFullScreen },
  { key = "w",          mods = "LEADER",         action = act.ShowTabNavigator },

  {
    key = ",",
    mods = "LEADER",
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
}

local key_bindings = {
  -- bashrc handles kill-backward in most shells now, so this shouldn't really
  -- be terminal-specific. Kept in case it's needed again.
  -- { key = "Backspace", mods = "CTRL", action = act.SendKey({ key = "Backspace", mods = "ALT" }) },
  { key = "Backspace", mods = "CTRL", action = act.SendKey({ key = "w", mods = "CTRL" }) },
}

local other_keybinds = {
  { key = "q", mods = "LEADER", action = act({ CloseCurrentTab = { confirm = false } }) }, -- q for quit
}

-- Later entries win, so the merge order determines precedence.
local function all_keybinds()
  local merged = merge_lists(default_keybinds, tmux_keybinds)
  merged = merge_lists(merged, key_bindings)
  merged = merge_lists(merged, other_keybinds)
  return merged
end

--- Everything except the tmux-style bindings. Used by the LEADER+Z toggle.
local function keybinds_without_tmux()
  local merged = merge_lists(default_keybinds, key_bindings)
  merged = merge_lists(merged, other_keybinds)
  return merged
end

---------------------------------------------------------------
--- 8. Key tables
---------------------------------------------------------------
local key_tables = {
  -- Modal tab navigation: LEADER+n, then h/l repeatedly, Escape to exit.
  nav = {
    { key = "h",      action = act.ActivateTabRelative(-1) },
    { key = "l",      action = act.ActivateTabRelative(1) },
    -- { key = "H",   action = act.MoveTabRelative(-1) },
    -- { key = "L",   action = act.MoveTabRelative(1) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q",      action = "PopKeyTable" },
  },

  resize_pane = {
    { key = "LeftArrow",  action = act({ AdjustPaneSize = { "Left", 1 } }) },
    { key = "h",          action = act({ AdjustPaneSize = { "Left", 1 } }) },
    { key = "RightArrow", action = act({ AdjustPaneSize = { "Right", 1 } }) },
    { key = "l",          action = act({ AdjustPaneSize = { "Right", 1 } }) },
    { key = "UpArrow",    action = act({ AdjustPaneSize = { "Up", 1 } }) },
    { key = "k",          action = act({ AdjustPaneSize = { "Up", 1 } }) },
    { key = "DownArrow",  action = act({ AdjustPaneSize = { "Down", 1 } }) },
    { key = "j",          action = act({ AdjustPaneSize = { "Down", 1 } }) },
    { key = "Escape",     action = "PopKeyTable" },
  },

  copy_mode = {
    {
      key = "Escape",
      mods = "NONE",
      action = act.Multiple({
        act.ClearSelection,
        act.CopyMode("ClearPattern"),
        act.CopyMode("Close"),
      }),
    },
    {
      key = "a",
      mods = "ALT|LEADER",
      action = act.Multiple({
        act.ClearSelection,
        act.CopyMode("ClearPattern"),
        act.CopyMode("Close"),
      }),
    },
    { key = "q",          mods = "NONE",  action = act.CopyMode("Close") },

    -- move cursor
    { key = "h",          mods = "NONE",  action = act.CopyMode("MoveLeft") },
    { key = "LeftArrow",  mods = "NONE",  action = act.CopyMode("MoveLeft") },
    { key = "j",          mods = "NONE",  action = act.CopyMode("MoveDown") },
    { key = "DownArrow",  mods = "NONE",  action = act.CopyMode("MoveDown") },
    { key = "k",          mods = "NONE",  action = act.CopyMode("MoveUp") },
    { key = "UpArrow",    mods = "NONE",  action = act.CopyMode("MoveUp") },
    { key = "l",          mods = "NONE",  action = act.CopyMode("MoveRight") },
    { key = "RightArrow", mods = "NONE",  action = act.CopyMode("MoveRight") },

    -- move by word
    { key = "RightArrow", mods = "ALT",   action = act.CopyMode("MoveForwardWord") },
    { key = "f",          mods = "ALT",   action = act.CopyMode("MoveForwardWord") },
    { key = "\t",         mods = "NONE",  action = act.CopyMode("MoveForwardWord") },
    { key = "w",          mods = "NONE",  action = act.CopyMode("MoveForwardWord") },
    { key = "LeftArrow",  mods = "ALT",   action = act.CopyMode("MoveBackwardWord") },
    { key = "b",          mods = "ALT",   action = act.CopyMode("MoveBackwardWord") },
    { key = "\t",         mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
    { key = "b",          mods = "NONE",  action = act.CopyMode("MoveBackwardWord") },
    {
      key = "e",
      mods = "NONE",
      action = act.Multiple({
        act.CopyMode("MoveRight"),
        act.CopyMode("MoveForwardWord"),
        act.CopyMode("MoveLeft"),
      }),
    },

    -- line start / end
    { key = "0",  mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    { key = "\n", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
    { key = "$",  mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "e",  mods = "CTRL", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "m",  mods = "ALT",  action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "^",  mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "a",  mods = "CTRL", action = act.CopyMode("MoveToStartOfLineContent") },

    -- select
    { key = " ",  mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "v",  mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    {
      key = "V",
      mods = "NONE",
      action = act.Multiple({
        act.CopyMode("MoveToStartOfLineContent"),
        act.CopyMode({ SetSelectionMode = "Cell" }),
        act.CopyMode("MoveToEndOfLineContent"),
      }),
    },

    -- copy
    {
      key = "y",
      mods = "NONE",
      action = act.Multiple({
        act({ CopyTo = "ClipboardAndPrimarySelection" }),
        act.CopyMode("Close"),
      }),
    },
    {
      key = "Y",
      mods = "NONE",
      action = act.Multiple({
        act.CopyMode({ SetSelectionMode = "Cell" }),
        act.CopyMode("MoveToEndOfLineContent"),
        act({ CopyTo = "ClipboardAndPrimarySelection" }),
        act.CopyMode("Close"),
      }),
    },

    -- scroll
    { key = "G",        mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "g",        mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
    { key = "H",        mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
    { key = "M",        mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
    { key = "L",        mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
    { key = "o",        mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
    { key = "O",        mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
    { key = "PageUp",   mods = "NONE", action = act.CopyMode("PageUp") },
    { key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
    { key = "b",        mods = "CTRL", action = act.CopyMode("PageUp") },
    { key = "f",        mods = "CTRL", action = act.CopyMode("PageDown") },
    { key = "Enter",    mods = "NONE", action = act.CopyMode("ClearSelectionMode") },

    -- search
    { key = "/",        mods = "NONE", action = act.Search("CurrentSelectionOrEmptyString") },
    {
      key = "n",
      mods = "NONE",
      action = act.Multiple({
        act.CopyMode("NextMatch"),
        act.CopyMode("ClearSelectionMode"),
      }),
    },
    {
      key = "N",
      mods = "NONE",
      action = act.Multiple({
        act.CopyMode("PriorMatch"),
        act.CopyMode("ClearSelectionMode"),
      }),
    },
  },

  search_mode = {
    { key = "Escape", mods = "NONE",       action = act.CopyMode("Close") },
    { key = "a",      mods = "ALT|LEADER", action = act.CopyMode("Close") },
    {
      key = "Enter",
      mods = "NONE",
      action = act.Multiple({
        act.CopyMode("ClearSelectionMode"),
        act.ActivateCopyMode,
      }),
    },
    { key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
    { key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
    { key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
    { key = "/", mods = "NONE", action = act.CopyMode("ClearPattern") },
    { key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
  },
}

-- NOTE: the duplicated `mods = "SHIFT"` variants for $, ^, G, V, Y and N were
-- dropped -- those characters already imply shift, so the SHIFT-qualified
-- entries never matched anything.

---------------------------------------------------------------
--- 9. Mouse
---------------------------------------------------------------
local mouse_bindings = {
  { event = { Up = { streak = 1, button = "Left" } },   mods = "NONE", action = act({ CompleteSelection = "PrimarySelection" }) },
  { event = { Up = { streak = 1, button = "Right" } },  mods = "NONE", action = act({ CompleteSelection = "Clipboard" }) },
  { event = { Up = { streak = 1, button = "Left" } },   mods = "CTRL", action = act.OpenLinkAtMouseCursor },
  -- Right-click pastes instead of copying the selection:
  -- { event = { Down = { streak = 1, button = "Right" } }, mods = "NONE", action = act.PasteFrom("Clipboard") },
  -- Stop the link-opening click from also reaching the application:
  { event = { Down = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.Nop },
}

---------------------------------------------------------------
--- 10. Tab bar
---------------------------------------------------------------
-- local LEFT_CAP = utf8.char(0xe0b6)  -- round left cap
-- local RIGHT_CAP = utf8.char(0xe0b4) -- round right cap
-- Angled alternatives:
-- local LEFT_CAP = utf8.char(0xe0b2)
-- local RIGHT_CAP = utf8.char(0xe0b0)
-- slash alternatives:
local LEFT_CAP = utf8.char(0xe0ba)  -- slash left cap
local RIGHT_CAP = utf8.char(0xe0bc) -- slash right cap

local ZOOM_ICON = "󰊓"
local DOT = "●"

local PROC_ICONS = {
  nvim = "󰈚",
  vim = "",
  git = "",
  lazygit = "",
  htop = "",
  btm = "",
  btop = "",
  ssh = "󰢹",
  docker = "",
  python = "",
  python3 = "",
  node = "",
  cargo = "",
  make = "",
  zsh = "",
  bash = "",
  fish = "",
  powershell = "",
  pwsh = "",
  wsl = "",
}

--- Any pane in the tab produced output we haven't looked at.
--- FIX: the old version only checked the active pane, so output in a
--- background split never raised the marker.
local function any_unseen_output(tab)
  for _, pane in ipairs(tab.panes or {}) do
    if pane.has_unseen_output then
      return true
    end
  end
  return false
end

--- Display title: explicit rename > process name > the pane's own title.
local function tab_title(tab, proc)
  local title = tab.tab_title
  if title and #title > 0 then
    return title
  end
  if proc and #proc > 0 then
    return proc
  end
  return tab.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
  local bg, fg
  if tab.is_active then
    bg, fg = palette.tab_active_bg, palette.tab_active_fg
  elseif hover then
    bg, fg = palette.tab_hover_bg, palette.tab_hover_fg
  else
    bg, fg = palette.tab_inactive_bg, palette.tab_inactive_fg
  end

  -- FIX: icons are keyed on the *process basename*, not on the display title.
  -- The old version looked up PROC_ICONS[title], which missed whenever the tab
  -- had been renamed or fell back to the pane title.
  local proc = basename(tab.active_pane.foreground_process_name)
  local icon = PROC_ICONS[proc:lower()]

  local title = tab_title(tab, proc)
  local index = tostring(tab.tab_index + 1)

  local zoomed = tab.active_pane.is_zoomed
  local unseen = (not tab.is_active) and any_unseen_output(tab)

  -- FIX: budget the real overhead (the old code hardcoded max_width - 6 and so
  -- overflowed, clipping the right cap) and clamp so a small max_width can't
  -- produce a negative width.
  local reserved = 2        -- both caps
      + (#index + 2)        -- " N "
      + (icon and 2 or 0)   -- "icon "
      + (zoomed and 2 or 0) -- " zoom"
      + (unseen and 2 or 0) -- " dot"
      + 1                   -- trailing space
  local room = math.max(max_width - reserved, 4)

  -- FIX: markers are appended *after* truncation. The old code appended the
  -- unseen-output dot first, so it was the first thing truncate_right cut.
  title = wezterm.truncate_right(title, room)

  local cells = {
    { Background = { Color = palette.bar_bg } },
    { Foreground = { Color = bg } },
    { Text = LEFT_CAP },
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
    { Text = " " .. index .. " " },
  }

  -- FIX: only emit the icon when there is one, otherwise the old
  -- string.format(" %d %s %s ", ...) left a double space.
  if icon then
    table.insert(cells, { Text = icon .. " " })
  end
  table.insert(cells, { Text = title })

  if zoomed then
    table.insert(cells, { Text = " " .. ZOOM_ICON })
  end
  if unseen then
    table.insert(cells, { Foreground = { Color = palette.alert } })
    table.insert(cells, { Text = " " .. DOT })
    table.insert(cells, { Foreground = { Color = fg } })
  end

  table.insert(cells, { Text = " " })
  table.insert(cells, { Background = { Color = palette.bar_bg } })
  table.insert(cells, { Foreground = { Color = bg } })
  table.insert(cells, { Text = RIGHT_CAP })

  return cells
end)

-- Plain tab titles (index: process name), no powerline caps. BACKUP ONLY --
-- do not enable this alongside the handler above, or it will win and the
-- powerline bar will silently stop rendering.
--
-- wezterm.on("format-tab-title", function(tab)
--   local proc = tab.active_pane.foreground_process_name or ""
--   local name = proc:match("([^/\\]+)$") or "shell"
--   return { { Text = string.format(" %d: %s ", tab.tab_index + 1, name) } }
-- end)

---------------------------------------------------------------
--- 11. Right status
---------------------------------------------------------------
-- Fires roughly once a second. Keep it cheap: never call
-- wezterm.run_child_process() in here. If you want the git branch, push it
-- from your shell prompt as a user var instead:
--
--   printf "\033]1337;SetUserVar=%s=%s\007" gitbranch \
--     "$(echo -n "$(git branch --show-current 2>/dev/null)" | base64)"
--
-- then read pane:get_user_vars().gitbranch below.
wezterm.on("update-right-status", function(window, pane)
  local cells = {}

  local ws = window:active_workspace()
  if ws ~= "default" then
    table.insert(cells, " " .. ws)
  end

  if window:leader_is_active() then
    table.insert(cells, "LEADER")
  end

  local kt = window:active_key_table()
  if kt then
    table.insert(cells, kt:upper())
  end

  -- local branch = pane:get_user_vars().gitbranch
  -- if branch and #branch > 0 then table.insert(cells, " " .. branch) end

  table.insert(cells, wezterm.strftime("%a %H:%M"))

  window:set_right_status(wezterm.format({
    { Foreground = { AnsiColor = "Teal" } },
    -- { Foreground = { AnsiColor = "Olive" } },
    { Text = " " .. table.concat(cells, " │ ") .. " " },
  }))
end)

-- Machine name in the upper right, with a leading separator. BACKUP ONLY --
-- same caveat as above: only one update-right-status handler should be active.
--
-- wezterm.on("update-right-status", function(window)
--   local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
--   local scheme = window:effective_config().resolved_palette
--   window:set_right_status(wezterm.format({
--     { Background = { Color = "none" } },
--     { Foreground = { Color = scheme.background } },
--     { Text = SOLID_LEFT_ARROW },
--     { Background = { Color = scheme.background } },
--     { Foreground = { Color = scheme.foreground } },
--     { Text = " " .. wezterm.hostname() .. " " },
--   }))
-- end)

---------------------------------------------------------------
--- 12. Custom events
---------------------------------------------------------------
-- FIX: the old config bound keys to EmitEvent "trigger-nvim-with-scrollback"
-- and EmitEvent "toggle-tmux-keybinds" but never registered a handler for
-- either, so both keys were silent no-ops.

--- LEADER+e -- dump this pane's scrollback into nvim
wezterm.on("trigger-nvim-with-scrollback", function(window, pane)
  local dims = pane:get_dimensions()
  local text = pane:get_lines_as_text(dims.scrollback_rows)

  local path = os.tmpname()
  local f = io.open(path, "w+")
  if not f then
    window:toast_notification("wezterm", "could not create a temp file", nil, 4000)
    return
  end
  f:write(text)
  f:flush()
  f:close()

  -- `+` opens at the last line, which is usually what you want from a dump.
  window:perform_action(act.SpawnCommandInNewTab({ args = { "nvim", "+", path } }), pane)

  -- Give nvim time to read the file before removing it.
  wezterm.sleep_ms(1000)
  os.remove(path)
end)

--- LEADER+Z -- toggle the tmux-style keybinds off and on.
--- Useful inside an actual tmux/nvim session when you want the LEADER and
--- ALT+SHIFT bindings to pass through untouched. Applies per-window via config
--- overrides, so other windows are unaffected.
wezterm.on("toggle-tmux-keybinds", function(window, pane)
  local overrides = window:get_config_overrides() or {}

  if overrides.keys then
    overrides.keys = nil
    window:toast_notification("wezterm", "tmux keybinds: on", nil, 2000)
  else
    overrides.keys = keybinds_without_tmux()
    window:toast_notification("wezterm", "tmux keybinds: off", nil, 2000)
  end

  window:set_config_overrides(overrides)
end)

-- Build a dev layout on launch: main pane plus a 35% right column split in
-- half. Uncomment and adjust the cwd.
--
-- wezterm.on("gui-startup", function(cmd)
--   local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
--   local right = pane:split({ direction = "Right", size = 0.35 })
--   right:split({ direction = "Bottom", size = 0.5 })
--   window:gui_window():maximize()
-- end)

-- Add your own entries to the command palette (LEADER+P) instead of burning
-- another keybinding on each one.
--
-- wezterm.on("augment-command-palette", function(window, pane)
--   return {
--     { brief = "Reload configuration", icon = "md_reload", action = act.ReloadConfiguration },
--     {
--       brief = "Rename workspace",
--       icon = "md_briefcase_edit",
--       action = act.PromptInputLine({
--         description = "New workspace name",
--         action = wezterm.action_callback(function(win, p, line)
--           if line and #line > 0 then
--             wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
--           end
--         end),
--       }),
--     },
--   }
-- end)

-- Only prompt on close for processes that actually hold state, so closing a
-- plain shell is instant.
--
-- wezterm.on("mux-is-process-stateful", function(proc)
--   local stateful = { nvim = true, vim = true, psql = true, ssh = true, python3 = true }
--   return stateful[(proc.name or ""):lower()] or false
-- end)

---------------------------------------------------------------
--- 13. Domains, default program, launch menu
---------------------------------------------------------------
local launch_menu = {}

-- Enumerates the installed distros (equivalent to `wsl -l -v`).
local WSL_DEFAULT = "WSL:Ubuntu"
local wsl_domains = wezterm.default_wsl_domains()
local have_wsl_default = false

for _, dom in ipairs(wsl_domains) do
  if dom.name == WSL_DEFAULT then
    dom.default_prog = { "bash" }
    -- Start in $HOME rather than /mnt/c/... . Replaces the broken `--cd ~`
    -- argument in the old default_prog.
    dom.default_cwd = "~"
    have_wsl_default = true
  end
end

config.wsl_domains = wsl_domains

-- FIX: the old config did
--
--   config.default_prog = { "powershell.exe", "-NoLogo", "wsl.exe", "--cd ~" }
--
-- which had two problems. "--cd ~" was a single argv token, so wsl.exe never
-- parsed it. More importantly, launching WSL *through* PowerShell means the
-- foreground process of every pane is powershell.exe/wsl.exe forever, so
-- format-tab-title can never report nvim/git/etc., and new splits don't
-- inherit the shell's working directory.
--
-- Using a domain instead gives WezTerm a native WSL session: correct process
-- reporting, correct CWD inheritance, and it shows up in the launcher.
if is_windows() then
  if have_wsl_default then
    config.default_domain = WSL_DEFAULT
  end

  table.insert(launch_menu, { label = "Local: PowerShell", args = { "powershell.exe", "-NoLogo" } })
  table.insert(launch_menu, { label = "Local: pwsh", args = { "pwsh.exe", "-NoLogo" } })
  table.insert(launch_menu, { label = "Local: cmd", args = { "cmd.exe" } })

  -- Force PowerShell as the shell instead of WSL:
  -- config.default_domain = "local"
  -- config.default_prog = { "powershell.exe", "-NoLogo" }
end

config.launch_menu = launch_menu

-- A unix domain keeps the mux server alive independently of the GUI, so panes
-- survive a window/GUI crash -- the one thing tmux gives you that plain
-- WezTerm doesn't. Enable both lines together.
-- config.unix_domains = { { name = "unix" } }
-- config.default_gui_startup_args = { "connect", "unix" }

-- Remote hosts as first-class domains (native rendering + scrollback).
-- config.ssh_domains = {
--   {
--     name = "devbox",
--     remote_address = "devbox.example.com",
--     username = "you",
--     multiplexing = "None", -- "WezTerm" if wezterm-mux-server runs there
--   },
-- }

---------------------------------------------------------------
--- 14. Config assembly
---------------------------------------------------------------
if color_scheme then
  config.color_scheme = color_scheme
end
-- config.color_scheme_dirs = { os.getenv("HOME") .. "/.config/wezterm/colors/" }

-- Character metrics.
-- NOTE: cell_width above 1.0 inserts space inside each cell, which shows as a
-- hairline seam between the tab-bar powerline caps and the tab body. Drop to
-- 1.0 if the tab bar looks gappy.
config.cell_width = 1.1
-- config.cell_width = 1.0
config.line_height = 1.1
-- config.line_height = 1.0
-- config.line_height = 1.2

config.font = font
config.font_size = font_size
-- Set to true temporarily when debugging missing Nerd Font icons.
config.warn_about_missing_glyphs = false

config.background = background
-- config.window_background_gradient = window_background_gradient
-- config.window_background_opacity = 0.98
-- config.win32_system_backdrop = "Tabbed" -- "Acrylic" | "Mica" | "Tabbed"
-- config.text_background_opacity = 0.3

-- Cursor. Valid styles: SteadyBlock, BlinkingBlock, SteadyUnderline,
-- BlinkingUnderline, SteadyBar, BlinkingBar.
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
-- config.force_reverse_video_cursor = true
-- Caps the frame rate for easing effects (cursor blink, blinking text, visual
-- bell). 1 effectively removes the animation cost.
config.animation_fps = 1

config.colors = {
  cursor_bg = palette.cursor_bg,
  cursor_fg = palette.cursor_fg,
  tab_bar = {
    -- FIX: `background` was unset, so the strip past the last tab did not match
    -- the tab edges drawn by the format-tab-title handler.
    background = palette.bar_bg,
    -- active_tab / inactive_tab are ignored while a custom format-tab-title
    -- handler is installed (it sets colours per-cell), but they still apply if
    -- you ever remove that handler.
    active_tab = { bg_color = palette.tab_active_bg, fg_color = palette.tab_active_fg },
    inactive_tab = { bg_color = palette.tab_inactive_bg, fg_color = palette.tab_inactive_fg },
    inactive_tab_hover = { bg_color = palette.tab_hover_bg, fg_color = palette.tab_hover_fg },
    new_tab = { bg_color = palette.bar_bg, fg_color = palette.tab_new_fg },
    new_tab_hover = { bg_color = palette.tab_hover_bg, fg_color = palette.tab_hover_fg },
  },
}

-- Tab bar layout. use_fancy_tab_bar MUST stay false: the fancy renderer draws
-- its own tab shape, which fights the powerline caps.
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true

-- Window
config.window_decorations = "TITLE|RESIZE"        -- "NONE" | "TITLE" | "RESIZE" | "TITLE|RESIZE"
config.window_padding = { left = 3, right = 0, top = 0, bottom = 0 }
config.window_close_confirmation = "AlwaysPrompt" -- "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.native_macos_fullscreen_mode = true
config.enable_scroll_bar = false
-- FIX: default is 3500, which is thin given the LEADER+e scrollback dump.
config.scrollback_lines = 10000
config.exit_behavior = "CloseOnCleanExit" -- "Close" | "Hold" | "CloseOnCleanExit"

-- Bell. Uncomment for a subtle flash instead of nothing.
-- config.audible_bell = "Disabled"
-- config.visual_bell = {
--   fade_in_function = "EaseIn",
--   fade_in_duration_ms = 150,
--   fade_out_function = "EaseOut",
--   fade_out_duration_ms = 150,
--   target = "CursorColor",
-- }

-- Selection / input
config.selection_word_boundary = " \t\n{}[]()\"'`,;:│=&!%"
config.use_ime = true
config.ime_preedit_rendering = "Builtin"
config.use_dead_keys = false
-- FIX: was true, which makes left-Ctrl+Alt act as AltGr and therefore swallows
-- the ALT|CTRL|SHIFT pane-resize bindings above. Set back to true only if you
-- need to type diacritics.
config.treat_left_ctrlalt_as_altgr = false
-- Default is already true on Windows; harmless elsewhere.
config.allow_win32_input_mode = true
-- Not recommended: changes the behaviour of some keys in backwards
-- incompatible ways.
-- config.enable_csi_u_key_encoding = true

-- Misc
config.automatically_reload_config = true
config.check_for_updates = false
-- FIX: was true, which logged every keystroke permanently. Flip on only while
-- diagnosing a key that won't fire, then flip back.
config.debug_key_events = false
config.enable_wayland = enable_wayland()

apply_renderer(config)

-- Keys
config.leader = { key = "a", mods = "ALT", timeout_milliseconds = 2000 }
config.disable_default_key_bindings = true
config.keys = all_keybinds()
config.mouse_bindings = mouse_bindings

-- Merge our key tables over the upstream defaults rather than replacing them
-- outright, so new upstream copy-mode/search-mode bindings keep working after
-- an upgrade while ours still take precedence.
local default_key_tables = {}
if wezterm.gui and wezterm.gui.default_key_tables then
  local ok, tables = pcall(wezterm.gui.default_key_tables)
  if ok and type(tables) == "table" then
    default_key_tables = tables
  end
end
config.key_tables = merge_key_tables(default_key_tables, key_tables)

---------------------------------------------------------------
--- 15. Hyperlinks
---------------------------------------------------------------
-- Start from the maintained upstream rules (URLs, bracketed URLs, mailto)
-- rather than hand-rolling them, then add our own on top.
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- FIX: the old org/repo rule made quotes optional, so any `foo/bar` in the
-- output -- including ordinary paths like src/main.rs -- became a clickable
-- GitHub link. Quotes are now required. (WezTerm's regex engine has no
-- lookahead, so excluding file extensions isn't an option.)
table.insert(config.hyperlink_rules, {
  regex = [["([\w\d][-\w\d]*)/([-\w\d.]+)"]],
  format = "https://github.com/$1/$2",
  highlight = 0,
})

-- Turn ticket IDs into links. Adjust the host before enabling.
-- table.insert(config.hyperlink_rules, {
--   regex = [[\b([A-Z]{2,}-\d+)\b]],
--   format = "https://your-jira.atlassian.net/browse/$1",
-- })

-- The previous hand-written rule set, kept as a backup. Replace
-- default_hyperlink_rules() above with this table to go back to it.
-- config.hyperlink_rules = {
--   { regex = "\\((\\w+://\\S+)\\)", format = "$1", highlight = 1 }, -- (URL)
--   { regex = "\\[(\\w+://\\S+)\\]", format = "$1", highlight = 1 }, -- [URL]
--   { regex = "\\{(\\w+://\\S+)\\}", format = "$1", highlight = 1 }, -- {URL}
--   { regex = "<(\\w+://\\S+)>",     format = "$1", highlight = 1 }, -- <URL>
--   { regex = "[^(]\\b(\\w+://\\S+[)/a-zA-Z0-9-]+)", format = "$1", highlight = 1 },
--   { regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b", format = "mailto:$0" },
-- }

-- QuickSelect patterns (LEADER+Enter). Defaults already cover URLs, hashes and
-- paths; these add a few more.
config.quick_select_patterns = {
  "[0-9a-f]{7,40}",                               -- git hashes
  "[a-zA-Z0-9_-]+\\.(?:log|json|ya?ml|toml|lua)", -- filenames
  "\\d{1,3}(\\.\\d{1,3}){3}",                     -- IPv4
}

-- and finally, return the configuration to wezterm
return config
