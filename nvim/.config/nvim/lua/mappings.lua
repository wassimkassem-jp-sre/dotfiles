require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- tmux-aware split navigation (vim-tmux-navigator)
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Window/pane left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Window/pane down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Window/pane up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Window/pane right" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- dap 
map("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "Toggle Python Breakpoint" })
map("n", "<F5>", "<cmd>DapContinue<CR>", { desc = "Start or continue DAP" })
map("n", "<F10>", "<cmd>DapStepOver<CR>", { desc = "Step over" })
map("n", "<F11>", "<cmd>DapStepInto<CR>", { desc = "Step into" })
map("n", "<F12>", "<cmd>DapStepOut<CR>", { desc = "Step out" })
