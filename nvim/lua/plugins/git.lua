return {
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"sindrets/diffview.nvim",
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewFileHistory",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
		},
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open diffview" },
			{ "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File history (repo)" },
		},
	},
	{
		"FabijanZulj/blame.nvim",
		event = "VeryLazy",
		config = function()
			require("blame").setup({
				virtual_style = "right_align",
			})
			vim.cmd("BlameToggle virtual")
		end,
		keys = {
			{ "<leader>gb", "<cmd>BlameToggle window<cr>", desc = "Toggle git blame window" },
			{ "<leader>gB", "<cmd>BlameToggle virtual<cr>", desc = "Toggle inline git blame" },
		},
	},
}
