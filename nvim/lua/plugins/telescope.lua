return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-tree/nvim-web-devicons" },
		{ "jvgrootveld/telescope-zoxide" },
		{ "debugloop/telescope-undo.nvim" },
		{ "nvim-telescope/telescope-frecency.nvim" },
		{ "nvim-telescope/telescope-live-grep-args.nvim" },
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		{ "ayamir/search.nvim"},
		{ "ayamir/project.nvim", event = { "CursorHold", "CursorHoldI" }},
		{ "aaronhallaert/advanced-git-search.nvim", 
		   cmd = { "AdvancedGitSearch" },
		   dependencies = {"tpope/vim-rhubarb","tpope/vim-fugitive","sindrets/diffview.nvim"},
		},
	},
    config = function()
        require('telescope').setup{}
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
    end,
}
