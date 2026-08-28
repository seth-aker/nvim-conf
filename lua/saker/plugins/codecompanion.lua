return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    interactions = {
      cli = {
	agent = "claude_code",
	agents = {
	  claude_code = {
	    cmd = "claude",
	    args = {},
	    description = "Claude Code CLI",
	    provider = "terminal",
	  }
	},
	opts = {
	  auto_insert = true,
	  reload = true,
	}
      }
    },
    adapters = {
      http = {
	ollama = function ()
		return require("codecompanion.adapters").extend("ollama", {
		  env = {
		    url = "http://localhost:11434"
		  }
	  })
	end,
      }
    },
    -- NOTE: The log_level is in `opts.opts`
    opts = {
      log_level = "DEBUG", -- or "TRACE"
    },
  },
}
