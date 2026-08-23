vim.api.nvim_create_autocmd('TermOpen', {
	group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})

-- Automatically reload files if they are changed externally (e.g., by Claude Code)
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	command = "if mode() != 'c' | checktime | endif",
})

vim.api.nvim_create_autocmd('CursorHold', {
	callback = function()
		vim.diagnostic.open_float(nil, {
			focusable = false,
			scope = 'cursor',
			close_events = { 'CursorMoved', 'InsertEnter', 'BufLeave' },
		})
	end
})

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('Custom-lsp-keybinds', { clear = true }),
	callback = function()
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to declaration' })
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Go to references' })
		vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format buffer' })
		vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
		vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {desc = 'Code action'})
	end,

})
