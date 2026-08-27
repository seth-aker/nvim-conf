return {
  'HiPhish/rainbow-delimiters.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    vim.g.rainbow_delimiters = {
      -- colors defined in colors.lua from the bearded palette; red excluded
      highlight = {
        'RainbowDelimiterYellow',
	'RainbowDelimiterBlue',
	'RainbowDelimiterOrange',
	'RainbowDelimiterCyan',
	'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
      },
    }
  end,
}
