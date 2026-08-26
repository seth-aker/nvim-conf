vim.g.mapleader = " "

--- NORMAL MODE ---
vim.keymap.set("n", "<leader>h", "<C-w>h")
vim.keymap.set("n", "<leader>j", "<C-w>j")
vim.keymap.set("n", "<leader>k", "<C-w>k")
vim.keymap.set("n", "<leader>l", "<C-w>l")

--- NEOTREE ---
vim.keymap.set("n", "<leader>cd", '<cmd>Neotree focus<CR>',
	{ noremap = true, silent = true, desc = "Focus Neo-tree window" })

--- TERMINAL ---
vim.keymap.set("n", "<leader>st", function()
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 15)
end
)

--- BUFFERLINE ---
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer tab" })
vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer tab" })
vim.keymap.set("n", "<leader>bd", function()
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].modified then
		vim.notify("Buffer has unsaved changes", vim.log.levels.WARN)
		return
	end
	-- point every window showing this buffer at another one first,
	-- so bdelete never closes a window
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		vim.api.nvim_win_call(win, function()
			local alt = vim.fn.bufnr("#")
			if alt > 0 and alt ~= buf and vim.bo[alt].buflisted then
				vim.cmd("buffer #")
			else
				pcall(vim.cmd.bprevious)
			end
		end)
	end
	pcall(vim.cmd.bdelete, buf)
end, { desc = "Close current buffer, keep window" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLinePickClose<CR>", { desc = "Pick a buffer tab to close" })
for i = 1, 9 do
	vim.keymap.set("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to buffer " .. i })
end


--- FLUTTER ---
vim.keymap.set('n', "<leader>FR", "<cmd>FlutterRun<CR>", { desc = "Run flutter debug session"})
vim.keymap.set('n', "<leader>FI", "<cmd>FlutterOpenDevTools<CR>", { desc = "Open flutter devtools"})


--- VISUAL MODE ---
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Moves selection up in visual mode" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Moves lines down in visual mode" })

--- TERMINAL MODE ---
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { silent = true, desc = "Leave terminal mode" })
