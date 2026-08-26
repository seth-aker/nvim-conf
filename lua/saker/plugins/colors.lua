return {
    {
	"Ferouk/bearded-nvim",
	name = "bearded",
	priority = 1000,
	config = function()
	    require("bearded").setup({
		flavor = "arc-eolstorm",
		italic = false,
		-- match VS Code, which colors keywords like const/class yellow
		on_highlights = function(set, palette)
		    set("@keyword", { fg = palette.colors.yellow })
		    set("@keyword.coroutine", { fg = palette.colors.yellow })
		    set("@keyword.exception", { fg = palette.colors.yellow })
		    -- java: keywords yellow, classes/records purple, variables orange
		    -- (jdtls semantic tokens sit on top of treesitter, so both layers need setting)
		    set("@keyword.type.java", { fg = palette.colors.yellow })
		    -- jdtls semantic-token layer, painted over treesitter: "modifier"
		    -- covers public/static/final (otherwise purple via @type.qualifier),
		    -- "keyword" covers contextual keywords like record/var/sealed
		    set("@lsp.type.modifier.java", { fg = palette.colors.yellow })
		    set("@lsp.type.keyword.java", { fg = palette.colors.yellow })
		    set("@variable.java", { fg = palette.colors.orange })
		    set("@lsp.type.variable.java", { fg = palette.colors.orange })
		    set("@lsp.type.class.java", { fg = palette.colors.purple })
		    set("@lsp.type.record.java", { fg = palette.colors.purple })
		    set("@lsp.type.interface.java", { fg = palette.colors.purple })
		    set("@lsp.type.enum.java", { fg = palette.colors.purple })
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
