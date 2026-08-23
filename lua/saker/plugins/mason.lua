return {
	"mason-org/mason.nvim",
	opts = {
		log_level = vim.log.levels.DEBUG,
		ui = {
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗"
			}
		},
	},
}
