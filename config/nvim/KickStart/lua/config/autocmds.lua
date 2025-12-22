-- -- Create group to assign commands
-- -- "clear = true" must be set to prevent loading an
-- -- auto-command repeatedly every time a file is resourced
-- local autocmd_group = vim.api.nvim_create_augroup("UserAutoCmds", { clear = true })

-- -- vim.api.nvim_create_autocmd({ 'BufEnter' }, {
-- -- command = "echo 'Welcome to LazyLite!'",
-- -- print("Welcome to LazyLite!")
-- -- callback = function()
-- -- print 'Welcome to LazyLite!'
-- -- end,
-- -- group = autocmd_group,
-- -- })

-- Check for external file changes (works with Claude Code)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Resize neovim split when terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("wincmd =")
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Enable spell checking for certain file types
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.txt", "*.md", "*.tex" },
  callback = function()
    vim.opt.spell = true
    vim.opt.spelllang = "en"
  end,
})

-- show cursor line only in active window
local cursorGrp = vim.api.nvim_create_augroup("CursorLine", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  pattern = "*",
  command = "set cursorline",
  group = cursorGrp,
})
vim.api.nvim_create_autocmd(
  { "InsertEnter", "WinLeave" },
  { pattern = "*", command = "set nocursorline", group = cursorGrp }
)

-- go to last loc when opening a buffer
-- this mean that when you open a file, you will be at the last position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Find what filetype this current buffer is
-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
--   callback = function()
--     vim.cmd(":set filetype?")
--   end,
--   group = autocmd_group,
-- })

-- I can't remember a time when I didn't want to save a file after tabbing away from my editor (especially with version control and Vim's persistent undo):
-- Currently it is having issues when a buffer is open with no name and focus is lost
-- vim.api.nvim_create_autocmd({ "FocusLost" }, {
--   desc = "Save on focus lost aka autosave",
--   callback = function()
--     vim.cmd(":wa")
--   end,
--   group = autocmd_group,
-- })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
})

-- don't auto comment new line
vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

local function toggle_plugins()
  local filepath = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype

  -- 1. Check File Size (e.g., disable if larger than 1MB)
  local max_filesize = 1024 * 1024 -- 1MB in bytes
  local ok, stats = pcall(vim.uv.fs_stat, filepath)
  local is_big = ok and stats and stats.size > max_filesize

  -- 2. Check File Type (add any types you want to ignore)
  local excluded_filetypes = { "bigfile", "log", "csv", "json" }
  local is_excluded_type = vim.tbl_contains(excluded_filetypes, filetype)

  local smear = require("smear_cursor")
  -- Toggle based on conditions
  if is_big or is_excluded_type then
    smear.enabled = false
  else
    smear.enabled = true
  end
end

-- Run every time you enter a buffer
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  pattern = "*",
  callback = function()
    -- Use pcall to prevent errors if the plugin isn't loaded yet
    pcall(toggle_plugins)
  end,
})

-- uv_close: Assertion '!uv__is_closing(handle)' failed fix on exit from a large file
vim.api.nvim_create_autocmd({ "VimLeave" }, {
  callback = function()
    vim.fn.jobstart('notify-send "hello"', { detach = true })
  end,
})
