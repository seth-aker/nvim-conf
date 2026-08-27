return {
	'nvim-telescope/telescope.nvim',
	version = '*',
	dependencies = {
		'nvim-lua/plenary.nvim',
		-- optional but recommended
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
	},
	config = function()
		require('telescope').setup({
			defaults = {
				-- lua patterns, matched anywhere in the relative path
				file_ignore_patterns = {
					'^target/', '/target/',
					'^build/', '/build/',
					'%.class$',
					'node_modules/',
					'^%.git/',
				},
			},
		})
		require('telescope').load_extension('fzf')

		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>ff', function()
			builtin.find_files({ hidden = true })
		end, { desc = 'Telescope find files' })
		vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
		vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
		vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
	end
}
