return {
  -- Ctrl-h/j/k/l moves across nvim splits and tmux panes (tmux side is in
  -- ~/.config/tmux/tmux.conf). Keymaps live in lua/mappings.lua so they
  -- override NvChad's default <C-hjkl> window mappings.
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },
  -- <leader>ff also lists dotfiles (.zshrc, .github/, ...). Gitignored files
  -- and .git/ stay hidden; <leader>fa still shows everything.
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      pickers = {
        find_files = {
          find_command = { "rg", "--files", "--color", "never", "--hidden", "--glob", "!**/.git/*" },
        },
      },
    },
  },
  -- GitHub PRs, reviews and issues inside nvim (talks to GitHub through `gh`,
  -- so `gh auth login` must work). Everything sits under <leader>o.
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = { picker = "telescope", enable_builtin = true },
    keys = {
      { "<leader>oo", "<cmd>Octo<CR>", desc = "Octo pick a command" },
      { "<leader>op", "<cmd>Octo pr list<CR>", desc = "Octo list PRs" },
      { "<leader>oc", "<cmd>Octo pr create<CR>", desc = "Octo create PR from this branch" },
      { "<leader>or", "<cmd>Octo review<CR>", desc = "Octo start or resume review" },
      { "<leader>oi", "<cmd>Octo issue list<CR>", desc = "Octo list issues" },
      { "<leader>os", "<cmd>Octo search<CR>", desc = "Octo search" },
    },
  },
  -- lazygit in a floating window. <leader>gg for the repo, <leader>gf for the
  -- current file's history.
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "lazygit" },
      { "<leader>gf", "<cmd>LazyGitFilterCurrentFile<CR>", desc = "lazygit current file history" },
    },
  },
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      git = {
        ignore = false, -- This stops nvim-tree from hiding git-ignored files
      },
    },
  },
  {
    'stevearc/conform.nvim',
    opts = {},
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- Point to your python executable or virtual environment path
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python" 
      -- Or use "python3" if debugpy is installed globally:
      require("dap-python").setup(path)
    end,
  },
  -- test new blink
  { import = "nvchad.blink.lazyspec" },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc",
       "html", "css", "python",
  		},
  	},
  },
}
