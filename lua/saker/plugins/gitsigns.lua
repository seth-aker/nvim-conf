return {
	'lewis6991/gitsigns.nvim',
	opts = {
		on_attach = function(bufnr)
			local gitsigns = require('gitsigns')

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map('n', ']c', function()
				if vim.wo.diff then
					vim.cmd.normal({ ']c', bang = true })
				else
					gitsigns.nav_hunk('next')
				end
			end, { desc = "Nav to next hunk"})

			map('n', '[c', function()
				if vim.wo.diff then
					vim.cmd.normal({ '[c', bang = true })
				else
					gitsigns.nav_hunk('prev')
				end
			end, { desc = "Nav to prev hunk"})

			-- Actions
			map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Stage git hunk"})
			map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Reset git hunk"})

			map('v', '<leader>hs', function()
				gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
			end, {desc = "Git stage selection"})

			map('v', '<leader>hr', function()
				gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
			end, { desc = "Git reset selection"})

			map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Git state buffer" })
			map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Git reset buffer" })
			map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Git preview hunk" })
			map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = "Git preview hunk inline" })

			map('n', '<leader>hb', function()
				gitsigns.blame_line({ full = true })
			end, { desc = "Git blame"})

			map('n', '<leader>hd', gitsigns.diffthis, { desc = "Git diff this"})

			map('n', '<leader>hD', function()
				gitsigns.diffthis('~')
			end, { desc = "Git diffthis ~"})

			map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
			map('n', '<leader>hq', gitsigns.setqflist)

			-- Toggles
			map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = "Toggle current line git blame" })
			map('n', '<leader>tw', gitsigns.toggle_word_diff, { desc = "Toggle word git diff" })

			-- Text object map({'o', 'x'}, 'ih', gitsigns.select_hunk)
		end
	}
}
