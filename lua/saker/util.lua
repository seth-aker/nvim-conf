local export = {}

local function new_terminal()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0,20)
end

export.new_terminal = new_terminal

return export

