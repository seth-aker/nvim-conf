-- Runs for every java buffer; start_or_attach reuses the client per project.
local jdtls = require("jdtls")

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
