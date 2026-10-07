-- `nvim <dir>` leaves cwd where nvim was launched, but launch.json discovery,
-- flutter-tools, the fvm SDK lookup, and envFromFile all resolve against cwd.
local launch_arg = vim.fn.argv(0) --[[@as string]]
if vim.fn.argc() == 1 and vim.fn.isdirectory(launch_arg) == 1 then
	vim.fn.chdir(launch_arg)
end

-- Adapters registered asynchronously, after the check below runs: flutter-tools
-- resolves the dart SDK first, and jdtls registers java from its on_attach.
local deferred_adapters = { dart = true, java = true }

-- jdtls (and with it the java adapter) only starts from ftplugin/java.lua, so
-- load a source file into a hidden, unlisted buffer to trigger it. Prefer a
-- launch.json main class so the file is guaranteed to be inside the project.
local function start_jdtls(root, configs)
	local file
	for _, config in ipairs(configs) do
		if config.type == "java" and config.mainClass then
			local suffix = "/" .. config.mainClass:gsub("%.", "/") .. ".java"
			file = vim.fs.find(function(name, path)
				return vim.endswith(path .. "/" .. name, suffix)
			end, { path = root, type = "file" })[1]
			if file then break end
		end
	end
	file = file or vim.fs.find(function(name) return name:match("%.java$") end, { path = root, type = "file" })[1]
	if file then
		local bufnr = vim.fn.bufadd(file)
		-- another nvim on the same project holds the swap file, and the E325 prompt
		-- would abort startup; the buffer is only a jdtls anchor, so skip the prompt
		local shortmess = vim.o.shortmess
		vim.opt.shortmess:append("A")
		vim.fn.bufload(bufnr)
		vim.o.shortmess = shortmess
		-- bufload skips filetype detection; the ftplugin resolves its root from buffer 0
		vim.api.nvim_buf_call(bufnr, function() vim.bo.filetype = "java" end)
	end
end

-- Deferred to VimEnter so every plugin is configured (notably dap.lua's json5
-- decoder, which launch.json files with trailing commas depend on).
vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("custom-project-debuggers", { clear = true }),
	once = true,
	callback = function()
		local root = vim.fn.getcwd()
		local is_flutter = vim.fn.filereadable(root .. "/pubspec.yaml") == 1
		if not is_flutter and vim.fn.filereadable(root .. "/.vscode/launch.json") == 0 then
			return
		end

		local dap = require("dap")
		local ok, configs = pcall(require("dap.ext.vscode").getconfigs)
		if not ok then
			vim.notify("launch.json: " .. configs, vim.log.levels.WARN)
			configs = {}
		end

		local types = {}
		for _, config in ipairs(configs) do
			types[config.type] = true
		end

		-- flutter-tools otherwise waits for a .dart buffer before registering its
		-- commands and dart adapter.
		if is_flutter or types.dart then
			require("flutter-tools").setup_project({})
		end
		if types.java then
			start_jdtls(root, configs)
		end

		local missing = vim.tbl_filter(function(type)
			return not dap.adapters[type] and not deferred_adapters[type]
		end, vim.tbl_keys(types))
		if #missing > 0 then
			table.sort(missing)
			vim.notify("launch.json: no debug adapter for " .. table.concat(missing, ", "), vim.log.levels.WARN)
		end
	end,
})
