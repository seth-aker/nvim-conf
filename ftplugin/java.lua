-- Runs for every java buffer; start_or_attach reuses the client per project.
local jdtls = require("jdtls")

-- The global <leader>f is vim.lsp.buf.format, but jdtls's Eclipse formatter fights the
-- google-java-format style our Java repos use, so java buffers format with that instead.
vim.keymap.set("n", "<leader>f", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local mason_gjf = vim.fn.stdpath("data") .. "/mason/bin/google-java-format"
    local cmd = vim.fn.executable(mason_gjf) == 1 and mason_gjf or "google-java-format"
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local result = vim.system({ cmd, "-" }, { stdin = table.concat(lines, "\n") .. "\n" }):wait()
    if result.code ~= 0 then
	vim.notify("google-java-format: " .. vim.trim(result.stderr or ""), vim.log.levels.ERROR)
	return
    end
    local formatted = vim.split(result.stdout, "\n", { plain = true })
    if formatted[#formatted] == "" then
	table.remove(formatted)
    end
    if vim.deep_equal(formatted, lines) then
	return
    end
    local view = vim.fn.winsaveview()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
    vim.fn.winrestview(view)
end, { buffer = true, desc = "Format buffer (google-java-format)" })

local root_dir = vim.fs.root(0, { "mvnw", "gradlew", "pom.xml", "build.gradle", ".git" })
if not root_dir then
    return
end

-- jdtls requires a separate workspace (index/cache) directory per project
local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. project_name

-- Debug + test support: loaded into jdtls as extension bundles
local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
local bundles = {
    vim.fn.glob(mason_packages .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"),
}
for _, jar in ipairs(vim.split(vim.fn.glob(mason_packages .. "/java-test/extension/server/*.jar"), "\n")) do
    -- the standalone test runner is not an eclipse bundle; including it breaks bundle loading
    if jar ~= "" and not jar:match("com%.microsoft%.java%.test%.runner%-jar%-with%-dependencies%.jar") then
	table.insert(bundles, jar)
    end
end

jdtls.start_or_attach({
    cmd = {
	vim.fn.stdpath("data") .. "/mason/bin/jdtls",
	"-data", workspace_dir,
    },
    root_dir = root_dir,
    init_options = {
	bundles = bundles,
    },
    on_attach = function(_, bufnr)
	jdtls.setup_dap({ hotcodereplace = "auto" })
	require("jdtls.dap").setup_dap_main_class_configs()

	local function map(lhs, rhs, desc)
	    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
	end
	map("<leader>tc", jdtls.test_class, "Debug test class")
	map("<leader>tm", jdtls.test_nearest_method, "Debug nearest test method")
    end,
})
