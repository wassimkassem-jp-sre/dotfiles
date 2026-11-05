-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "catppuccin",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

-- Statusline: git branch and +added ~changed -removed counts (from gitsigns)
-- sit on the right, next to the LSP name, folder and cursor position.
-- NvChad's default has "git" on the left, right after the file name.
M.ui = {
  statusline = {
    order = { "mode", "file", "%=", "lsp_msg", "%=", "diagnostics", "git", "lsp", "cwd", "cursor" },
  },
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

return M
