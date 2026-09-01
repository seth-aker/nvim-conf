return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
      "saifulapm/neotree-file-nesting-config",
    },
    lazy = false, -- neo-tree will lazily load itself
    opts = {
      filesystem = {
        use_libuv_file_watcher = true,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          never_show = { ".git", ".DS_Store", },
        },
      },
      source_selector = {
	winbar = true,
	statusline = true,
      },
      default_componenet_configs = {
	indent = {
	  with_expanders = true,
	  expander_collapsed = '',
          expander_expanded = '',
	},
      },
      close_if_last_window = true,
    },
  },
  {
    "Crysthamus/nvim-file-operations",
    -- branch = "compat" -- if you are on Neovim <= 0.10
    dependencies = {
      "nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
    },
    config = function()
      require("nvim-file-operations").setup()
    end,
  },
}

