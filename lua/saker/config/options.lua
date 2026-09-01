-- 24-bit color, required by bufferline
vim.o.termguicolors = true

-- show line numbers
vim.o.number = true
vim.o.relativenumber = true

-- show the cursor's line
vim.o.cursorline = true

-- indent width
vim.o.shiftwidth = 2
vim.o.autoindent = true
vim.o.smartindent = true

-- allow undo/redo even after file has been closed and reopened
vim.o.undofile = true

-- Enable mouse mode, for window resizing
vim.o.mouse = 'a'

-- case-insensitive search UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- new window behavior
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '.', nbsp = '␣' }

-- Preview substitutions live
vim.o.inccommand = 'split'

vim.o.confirm = true

vim.o.scrolloff = 10

-- sync with system clipboard
vim.o.clipboard = "unnamedplus"

vim.o.updatetime = 50

-- what gets captured in a session, recommended by auto-session
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions"

vim.o.colorcolumn = "100"

vim.o.hlsearch = true

vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = false,
	float = {
		border = 'rounded',
		source = true,
	},
})


-- Any .json file in .vscode/ folder gets parsed as json5 (comments, trailing commas allowed, etc)
vim.filetype.add({
  pattern = {
    ['.*/%.vscode/.*%.json'] = 'json5',
  },
})
