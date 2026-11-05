require "nvchad.autocmds"

-- Opening or moving into a terminal window (Ctrl-h/j/k/l, mouse, :wincmd) starts in
-- terminal mode so you can type straight away. Ctrl-x goes back to normal mode.
vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter", "WinEnter" }, {
  pattern = "term://*",
  callback = function()
    vim.cmd.startinsert()
  end,
})
