return {
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "neovim/nvim-lspconfig" },
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					null_ls.builtins.formatting.prettier,
					null_ls.builtins.formatting.gofumpt,
					null_ls.builtins.formatting.goimports,
					null_ls.builtins.formatting.clang_format,
				},
				-- No on_attach/BufWritePre — formatting is manual via <leader>fo
			})

			-- Quick Ruff fix for Python files
			vim.api.nvim_create_user_command("RuffFixFile", function()
				local file = vim.fn.expand("%:p")
				if file == "" then return end
				vim.cmd("write")
				vim.fn.jobstart({ "ruff", "check", "--fix", file }, { stdout_buffered = true, stderr_buffered = true })
				vim.fn.jobstart({ "ruff", "format", file }, { stdout_buffered = true, stderr_buffered = true })
				vim.cmd("edit")
			end, {})
		end,
	},
	{
		"jay-babu/mason-null-ls.nvim",
		dependencies = { "williamboman/mason.nvim", "nvimtools/none-ls.nvim" },
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = {
					"stylua", "prettier", "gofumpt", "goimports", "rustfmt", "ruff", "clang-format",
				},
				automatic_installation = true,
			})
		end,
	},
	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp", "objc", "objcpp" },
		opts = { inlay_hints = { inline = false } },
		keys = {
			{
				"<leader>ch",
				"<cmd>ClangdSwitchSourceHeader<cr>",
				ft = { "c", "cpp", "objc", "objcpp" },
				desc = "Switch source/header",
			},
		},
	},
	{
		"folke/trouble.nvim",
		opts = {},
		cmd = "Trouble",
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
			{ "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
			{ "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP info" },
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
		},
	},
	{
		"chrisgrieser/nvim-rulebook",
		keys = {
			{ "<leader>ri", function() require("rulebook").ignoreRule() end, desc = "Ignore rule" },
			{ "<leader>rl", function() require("rulebook").lookupRule() end, desc = "Lookup rule" },
			{ "<leader>ry", function() require("rulebook").yankDiagnosticCode() end, desc = "Yank diagnostic code" },
			{ "<leader>rs", function() require("rulebook").suppressFormatter() end, desc = "Suppress formatter" },
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{ "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer keymaps" },
		},
	},
}
