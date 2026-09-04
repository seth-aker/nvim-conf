return {
	'nvim-flutter/flutter-tools.nvim',
	lazy = false,
	dependencies = {
		'nvim-lua/plenary.nvim',
		'stevearc/dressing.nvim',     -- optional for vim.ui.select
	},
	opts = function()
		local opts = {
			fvm = true,
			dev_log = { enabled = false },
			debugger = {
		  enabled = true,
		  run_via_dap = true,
		  register_configurations = function(_)
		    local dart_configs = vim.tbl_filter(
		      function(c) return c.type == "dart" end,
		      require("dap.ext.vscode").getconfigs()
		    )
		    if #dart_configs > 0 then
		      require("dap").configurations.dart = dart_configs
		    end
		  end,
			},
		}
		local sdk = vim.fn.glob("{.,*}/.fvm/flutter_sdk/bin/flutter", true, true)[1]
		if sdk then opts.flutter_path = vim.fn.fnamemodify(sdk, ":p") end
		return opts
	end,
}
