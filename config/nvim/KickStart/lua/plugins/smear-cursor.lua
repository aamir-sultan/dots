return {
  "sphamba/smear-cursor.nvim",
  version = 'v0.6.0',
  lazy = true,
  event = 'CursorMoved',

  -- Only load if the file opened at startup is under 1MB
  -- cond = function()
  -- local file = vim.fn.argv(0)
  -- if file and file ~= "" then
  --   local stats = vim.uv.fs_stat(file)
  --   return not (stats and stats.size > 1024 * 1024)
  -- end
  -- return true
  -- end,

  -- cond = function()
  --   local filepath = vim.api.nvim_buf_get_name(0)
  --   local filetype = vim.bo.filetype
  --
  --   -- 1. Check File Size (e.g., disable if larger than 1MB)
  --   local max_filesize = 1024 * 1024 -- 1MB in bytes
  --   local ok, stats = pcall(vim.uv.fs_stat, filepath)
  --   local is_big = ok and stats and stats.size > max_filesize
  --
  --   -- 2. Check File Type (add any types you want to ignore)
  --   local excluded_filetypes = { "bigfile", "log", "csv", "json" }
  --   local is_excluded_type = vim.tbl_contains(excluded_filetypes, filetype)
  --
  --   -- Toggle based on conditions
  --   if is_big or is_excluded_type then
  --     return false
  --   else
  --     return true
  --   end
  -- end,

  opts = {
    cursor_color = "#D66924",
    -- Sets animation framerate
    time_interval = 17, -- milliseconds
    -- Smear cursor when switching buffers or windows
    smear_between_buffers = true,

    -- Smear cursor when moving within line or to neighbor lines
    -- Use `min_horizontal_distance_smear` and `min_vertical_distance_smear` for finer control
    smear_between_neighbor_lines = true,

    -- Only smear cursor when moving at least these distances
    min_horizontal_distance_smear = 2,
    min_vertical_distance_smear = 2,

    -- Toggles for directions
    smear_horizontally = true,
    smear_vertically = true,
    smear_diagonally = true, -- Neither horizontal nor vertical

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
