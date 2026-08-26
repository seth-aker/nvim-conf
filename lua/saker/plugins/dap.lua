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
		require('dap.ext.vscode').json_decode = require'json5'.parse
		dap.listeners.after.event_initialized.dapui = function() dapui.open() end
		dap.listeners.before.event_terminated.dapui = function() dapui.close() end
		dap.listeners.before.event_exited.dapui = function() dapui.close() end
	end,
}
