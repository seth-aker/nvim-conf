return {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function()
	require("nvim-treesitter").install({
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
	})

	-- the main branch no longer starts highlighting via setup(); it must be
	-- started per buffer, and silently does nothing without this autocmd
	vim.api.nvim_create_autocmd("FileType", {
	    group = vim.api.nvim_create_augroup("treesitter-highlight", { clear = true }),
	    callback = function(args)
		if pcall(vim.treesitter.start, args.buf) then
		    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	    end,
	})
    end
}
