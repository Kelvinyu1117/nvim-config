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
}
