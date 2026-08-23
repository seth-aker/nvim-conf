require('saker')
-- Enable every server with a config file in ~/.config/nvim/lsp/,
-- except servers managed by their own plugin (jdtls via nvim-jdtls).
local exclude = { jdtls = true }

for name, type in vim.fs.dir(vim.fn.stdpath('config') .. '/lsp') do
    if type == 'file' and name:match('%.lua$') then
	local server = name:sub(1, -5)
	if not exclude[server] then
	    vim.lsp.enable(server)
	end
    end
end
