return {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
        suppressed_dirs = { "~/", "~/Downloads", "/" },
        post_restore_cmds = {
            -- visit each restored buffer once so neo-tree's follow_current_file
            -- (with leave_dirs_open) expands the tree to all of them; its follow
            -- handler is debounced at 100ms, so steps must be spaced past that
            function()
                local win = vim.api.nvim_get_current_win()
                if vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "" then
                    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                        if vim.bo[vim.api.nvim_win_get_buf(w)].buftype == "" then
                            win = w
                            break
                        end
                    end
                end
                local original = vim.api.nvim_win_get_buf(win)
                local bufs = vim.tbl_filter(function(b)
                    return vim.bo[b].buflisted and vim.api.nvim_buf_get_name(b) ~= ""
                end, vim.api.nvim_list_bufs())
                local i = 0
                local function step()
                    if not vim.api.nvim_win_is_valid(win) then
                        return
                    end
                    i = i + 1
                    local b = bufs[i]
                    if b == nil then
                        if vim.api.nvim_buf_is_valid(original) then
                            vim.api.nvim_win_set_buf(win, original)
                        end
                        return
                    end
                    if vim.api.nvim_buf_is_valid(b) then
                        vim.api.nvim_win_set_buf(win, b)
                    end
                    vim.defer_fn(step, 200)
                end
                -- give neo-tree a moment to finish opening before the walk
                vim.defer_fn(step, 300)
            end,
        },
    },
}
