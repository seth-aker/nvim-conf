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
		{ "<leader>db", function() require("dap").toggle_breakpoint() end,                         desc = "Toggle breakpoint" },
		{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
		{ "<leader>dr", function() require("dap").repl.toggle() end,                               desc = "Toggle DAP repl" },
		{ "<leader>du", function() require("dapui").toggle() end,                                  desc = "Toggle DAP UI" },
		{ "<leader>dq", function() require("dap").terminate() end,                                 desc = "Terminate debug session" },
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		dapui.setup()
		require('dap.ext.vscode').json_decode = require 'json5'.parse
		dap.listeners.after.event_initialized.dapui = function() dapui.open() end
		dap.listeners.before.event_terminated.dapui = function() dapui.close() end
		dap.listeners.before.event_exited.dapui = function() dapui.close() end
		require("dap-python").setup("debugpy-adapter")

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

		local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

		local current_file = vim.fn.expand("%:t")

		local vscode = require("dap.ext.vscode")
		vscode.type_to_filetypes["node"] = js_filetypes
		vscode.type_to_filetypes["pwa-node"] = js_filetypes

		for _, language in ipairs(js_filetypes) do
			if not dap.configurations[language] then
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
					{
						name = "tsx (" .. current_file .. ")",
						type = "node",
						request = "launch",
						program = "${file}",
						runtimeExecutable = "tsx",
						cwd = "${workspaceFolder}",
						console = "integratedTerminal",
						internalConsoleOptions = "neverOpen",
						skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
					}
				}
			end
		end
	end,
}
