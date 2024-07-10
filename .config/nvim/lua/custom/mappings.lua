local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Add breakpoint at line",
    },
    ["<leader>dc"] = {
      "<cmd> DapToggleBreakpointCondition <CR>",
      "Add a conditional breakpoint at line",
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Start or continue the debugger",
    },
    ["<leader>di"] = {
      "<cmd> DapStepIn <CR>",
      "Step into the first line of the method",
    },
    ["<leader>du"] = {
      "<cmd> DapStepOut <CR>",
      "Step out from the current method and go to the caller method",
    },
    ["<leader>do"] = {
      "<cmd> DapStepOver <CR>",
      "Step over the next method even if it contains a call to an operation",
    },
  }
}

M.lazygit = {
  n = {
    ["<leader>lg"] = {
      "<cmd> LazyGit <CR>"
    }
  }
}

M.copilot = {
  i = {
    ["<C-j>"] = {
      function()
        vim.fn.feedkeys(vim.fn['copilot#Accept'](), '')
      end,
      "Copilot Accept",
      {replace_keycodes = true, nowait=true, silent=true, expr=true, noremap=true}
    }
  }
}

return M
