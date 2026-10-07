return {
	"mfussenegger/nvim-dap",
	dependencies = {
		{
			"rcarriga/nvim-dap-ui",
			dependencies = { "nvim-neotest/nvim-nio" },
		},
		{
			"theHamsta/nvim-dap-virtual-text",
			opts = {},
		},
		{
			"mfussenegger/nvim-dap-python",
		}
	},
	keys = {
		{ "<F5>",       function() require("dap").continue() end,                                  desc = "DAP continue/start" },
		{ "<F10>",      function() require("dap").step_over() end,                                 desc = "DAP step over" },
		{ "<F11>",      function() require("dap").step_into() end,                                 desc = "DAP step into" },
		{ "<F12>",      function() require("dap").step_out() end,                                  desc = "DAP step out" },
		{ "<leader>dc", function() require("dap").continue() end,                                  desc = "DAP continue/start" },
		{ "<leader>do", function() require("dap").step_over() end,                                 desc = "DAP step over" },
		{ "<leader>di", function() require("dap").step_into() end,                                 desc = "DAP step into" },
		{ "<leader>dO", function() require("dap").step_out() end,                                  desc = "DAP step out" },
		{ "<leader>db", function() require("dap").toggle_breakpoint() end,                         desc = "Toggle breakpoint" },
		{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
		{ "<leader>dr", function() require("dap").repl.toggle() end,                               desc = "Toggle DAP repl" },
		{ "<leader>du", function() require("dapui").toggle() end,                                  desc = "Toggle DAP UI" },
		{ "<leader>dq", function() require("dap").terminate() end,                                 desc = "Terminate debug session" },
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		dapui.setup(
		  -- {
		-- 	layouts = {
		-- 		{
		-- 			elements = {
		-- 				{ id = "scopes",      size = 0.25 },
		-- 				{ id = "breakpoints", size = 0.25 },
		-- 				{ id = "stacks",      size = 0.25 },
		-- 				{ id = "watches",     size = 0.25 },
		-- 			},
		-- 			position = "left",
		-- 			size = 40,
		-- 		},
		-- 		{
		-- 			elements = {
		-- 				{ id = "repl", size = 1.0 },
		-- 			},
		-- 			position = "bottom",
		-- 			size = 10,
		-- 		},
		-- 	},
		-- }
	      )
		require('dap.ext.vscode').json_decode = require 'json5'.parse
		dap.listeners.after.event_initialized.dapui = function() dapui.open() end

		-- dap-ui hands nvim-dap the same "DAP Console" buffer for every runInTerminal. On a
		-- restart the previous debuggee (e.g. a JVM running shutdown hooks) can still own that
		-- terminal, and jobstart refuses to open a terminal in it ("requires unmodified buffer").
		-- Retire the stale console so dap-ui creates a fresh one in the same window; if a live
		-- session still owns it, give the new session its own split instead.
		local dapui_console = dap.defaults.fallback.terminal_win_cmd
		dap.defaults.fallback.terminal_win_cmd = function(config)
			local buf = dapui_console(config)
			if vim.bo[buf].buftype ~= "terminal" then
				return buf
			end
			for _, s in pairs(dap.sessions()) do
				if s.term_buf == buf then
					local cur_win = vim.api.nvim_get_current_win()
					vim.cmd("belowright new")
					local split_buf, split_win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
					vim.api.nvim_set_current_win(cur_win)
					return split_buf, split_win
				end
			end
			local wins = vim.fn.win_findbuf(buf)
			local placeholder = vim.api.nvim_create_buf(false, true)
			-- dap-ui's force_buffers autocmd would put the stale console straight back, and
			-- deleting it while shown closes the window
			local eventignore = vim.o.eventignore
			vim.o.eventignore = "BufWinEnter,BufWinLeave"
			local ok, err = pcall(function()
				for _, win in ipairs(wins) do vim.api.nvim_win_set_buf(win, placeholder) end
			end)
			vim.o.eventignore = eventignore
			assert(ok, err)
			vim.api.nvim_buf_delete(buf, { force = true })
			local fresh = dapui_console(config)
			for _, win in ipairs(wins) do vim.api.nvim_win_set_buf(win, fresh) end
			vim.api.nvim_buf_delete(placeholder, { force = true })
			return fresh
		end

		-- setup python
		require("dap-python").setup("debugpy-adapter")

		-- setup javascript/typescript
		if not dap.adapters["pwa-node"] then
			local mason_root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
			require('dap').adapters['pwa-node'] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					args = {
						mason_root .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
						"${port}",
					},
				},
			}
		end
		if not dap.adapters["node"] then
			dap.adapters["node"] = function(cb, config)
				if config.type == "node" then
					config.type = "pwa-node"
				end
				local nativeAdapter = dap.adapters["pwa-node"]
				if type(nativeAdapter) == "function" then
					nativeAdapter(cb, config)
				else
					cb(nativeAdapter)
				end
			end
		end
		-- VS Code's "node-terminal" type just runs `command` in a terminal. js-debug's standalone
		-- server ends these sessions without running anything (it relies on VS Code's terminal
		-- API), so run the command ourselves. The adapter callback is deliberately never called:
		-- there is no debug session to start.
		if not dap.adapters["node-terminal"] then
			dap.adapters["node-terminal"] = function(_, config)
				vim.cmd.new()
				vim.cmd.wincmd("J")
				vim.api.nvim_win_set_height(0, 20)
				vim.fn.jobstart(config.command, {
					term = true,
					cwd = config.cwd or vim.fn.getcwd(),
					env = config.env,
				})
			end
		end

		local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

		local function package_root()
			return vim.fs.root(0, "package.json") or vim.fn.getcwd()
		end

		-- js-debug only resolves bare runtimeExecutable names against PATH
		-- (node_modules/.bin lookup needs VS Code's __workspaceFolder), so
		-- walk up from the file to find the project-local tsx ourselves.
		local function tsx_cmd()
			for dir in vim.fs.parents(vim.api.nvim_buf_get_name(0)) do
				local tsx = dir .. "/node_modules/.bin/tsx"
				if vim.uv.fs_stat(tsx) then return tsx end
			end
			return "tsx"
		end

		local vscode = require("dap.ext.vscode")
		vscode.type_to_filetypes["node"] = js_filetypes
		vscode.type_to_filetypes["pwa-node"] = js_filetypes

		-- The picker merges dap.configurations with launch.json, but flutter-tools copies the
		-- launch.json dart configs into dap.configurations, and jdtls re-adds its discovered
		-- main classes on every buffer attach (deduping on cwd, which can differ). Treat
		-- launch.json as authoritative and drop anything it already covers, by name or by
		-- java main class (the launch.json entry is the one carrying envFromFile).
		local global_configs = dap.providers.configs["dap.global"]
		dap.providers.configs["dap.global"] = function(bufnr)
			local ok, launch_configs = pcall(vscode.getconfigs)
			if not ok then launch_configs = {} end
			local seen_names, launch_main_classes = {}, {}
			for _, config in ipairs(launch_configs) do
				seen_names[config.name] = true
				if config.mainClass then launch_main_classes[config.mainClass] = true end
			end
			return vim.tbl_filter(function(config)
				if seen_names[config.name] or launch_main_classes[config.mainClass or ""] then
					return false
				end
				seen_names[config.name] = true
				return true
			end, global_configs(bufnr))
		end

		for _, language in ipairs(js_filetypes) do
			local is_typescript = vim.startswith(language, "typescript")
			if not dap.configurations[language] then
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = package_root,
						runtimeExecutable = is_typescript and tsx_cmd or nil,
						skipFiles = is_typescript and { "<node_internals>/**", "**/node_modules/**" } or nil,
					},
				}
			end
		end

		-- setup java and pull in secrets.json
		dap.listeners.on_config["envFromFile"] = function(config)
			if not config.envFromFile then return config end
			config = vim.deepcopy(config)
			config.env = config.env or {}
			for var, path in pairs(config.envFromFile) do
				path = path:gsub("%${workspaceFolder}", vim.fn.getcwd())
				if vim.fn.filereadable(path) == 1 then
					config.env[var] = table.concat(vim.fn.readfile(path), "")
				else
					vim.notify("envFromFile: cannot read " .. path, vim.log.levels.WARN)
				end
			end
			config.envFromFile = nil
			return config
		end
	end,
}
