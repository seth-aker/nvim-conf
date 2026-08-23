return {
    {
	"Ferouk/bearded-nvim",
	name = "bearded",
	priority = 1000,
	config = function()
	    require("bearded").setup({
		flavor = "arc-eolstorm",
		-- match VS Code, which colors keywords like const/class yellow
		on_highlights = function(set, palette)
		    set("@keyword", { fg = palette.colors.yellow })
		    set("@keyword.coroutine", { fg = palette.colors.yellow })
		    set("@keyword.exception", { fg = palette.colors.yellow })
		    -- legacy vim syntax groups (dart buffers use these, not treesitter)
		    set("Keyword", { fg = palette.colors.yellow })
		    set("Exception", { fg = palette.colors.yellow })
		    -- neo-tree git status: new = green, modified = blue, staged = yellow
		    set("NeoTreeGitUntracked", { fg = palette.colors.green })
		    set("NeoTreeGitAdded", { fg = palette.colors.yellow })
		    set("NeoTreeGitModified", { fg = palette.colors.blue })
		    set("NeoTreeGitStaged", { fg = palette.colors.yellow })
		    set("NeoTreeGitUnstaged", { fg = palette.colors.blue })
		    set("NeoTreeGitConflict", { fg = palette.colors.red })
		    set("NeoTreeGitDeleted", { fg = palette.colors.red })
		end,
	    })
	    vim.cmd.colorscheme "bearded"
	end
    },
}
