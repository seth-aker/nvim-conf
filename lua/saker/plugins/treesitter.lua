return {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function()
	local configs = require("nvim-treesitter.config")
	configs.setup({
	    highlight = {
		enable = true,
	    },
	    indent = {
		enable = true,
	    },
	    autotage = {
		enable = true,
	    },
	    ensure_installed = {
		"lua",
		"typescript",
		"java",
		"dart",
		"javascript",
		"json",
		"markdown",
		"yaml",
		"xml",
		"vue",
		"sql",
		"css",
		"dockerfile",
	    },
	    auto_install = false,
	})
    end
}
