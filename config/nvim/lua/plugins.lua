local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	{
		"folke/neodev.nvim",
		opts = {},
		config = function()
			require("neodev").setup({})
		end,
	},
	{
		"saecki/crates.nvim",
		tag = "stable",
		config = function()
			require("crates").setup()
		end,
	},
	{
		"y3owk1n/undo-glow.nvim",
	},
	{
		"AlejandroSuero/freeze-code.nvim",
		-- TODO: Add Uuid Image Names
		config = function()
			require("freeze-code").setup()
		end,
		opts = {
			copy = false,
			open = true,
			dir = vim.env.PWD,
			freeze_config = {
				output = "freeze.png",
				config = "base",
				theme = "default",
			},
		},
	},
	{
		"neolooong/whichpy.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		opts = {},
	},
	{
		"ldelossa/gh.nvim",
		dependencies = {
			{
				"ldelossa/litee.nvim",
				config = function()
					require("litee.lib").setup()
				end,
			},
		},
		config = function()
			require("litee.gh").setup()
		end,
	},
	{
		"sphamba/smear-cursor.nvim",
		opts = {},
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup({})
		end,
	},
	{
		"f-person/git-blame.nvim",
		event = "VeryLazy",
		opts = {
			enabled = true,
			message_template = " <summary> • <date> • <author> • <<sha>>",
			date_format = "%m-%d-%Y %H:%M:%S",
			virtual_text_column = 1,
		},
	},
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			require("gruvbox").setup({
				terminal_colors = true,
				undercurl = true,
				underline = true,
				bold = true,
				italic = {
					strings = false,
					comments = true,
					operators = false,
					folds = true,
				},
				palette_overrides = {},
				overrides = {},
			})
			vim.o.background = "dark"
			vim.cmd("colorscheme gruvbox")
		end,
	},
	{
		"azratul/live-share.nvim",
		dependencies = {
			"jbyuki/instant.nvim",
		},
		config = function()
			vim.g.instant_username = "Ranuga-Mac" -- Any name they want
			require("live-share").setup({})
		end,
	},
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				keymaps = {
					accept_suggestion = "<C-y>",
					clear_suggestion = "<C-e>",
					accept_word = "<C-l>",
				},
			})
		end,
	},
	{
		"alexghergh/nvim-tmux-navigation",
		config = function()
			local nav = require("nvim-tmux-navigation")

			nav.setup({
				disable_when_zoomed = true, -- don't navigate when tmux pane is zoomed
			})

			local opts = { noremap = true, silent = true }
			-- TODO: Integrate
			-- vim.keymap.set("n", "<C-h>", nav.NvimTmuxNavigateLeft, opts)
			-- vim.keymap.set("n", "<C-j>", nav.NvimTmuxNavigateDown, opts)
			-- vim.keymap.set("n", "<C-k>", nav.NvimTmuxNavigateUp, opts)
			-- vim.keymap.set("n", "<C-l>", nav.NvimTmuxNavigateRight, opts)
			vim.keymap.set("n", "<C-Space>", nav.NvimTmuxNavigateNext, opts)
		end,
	},
	{
		"nvim-java/nvim-java",
		config = function()
			require("java").setup()
		end,
	},
	{
		"folke/trouble.nvim",
		lazy = false,
		opts = {},
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nmac427/guess-indent.nvim",
		config = function()
			require("guess-indent").setup({})
		end,
	},
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				view = {
					side = "right",
					width = 30,
				},
			})
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8", -- Use a stable version
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({})
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
		end,
	},
	{ "github/copilot.vim" },
	{ 'diogo464/kubernetes.nvim' } ,{
	"xiyaowong/transparent.nvim",
	lazy = false,
	config = function()
		require("transparent").setup({
			exclude_groups = {},
		})

		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
	end,
},
	{
		"chrisgrieser/nvim-rulebook",
		lazy = false,
		keys = {
			{
				"<leader>ri",
				function()
					require("rulebook").ignoreRule()
				end,
				desc = "Ignore diagnostic rule",
			},
			{
				"<leader>rl",
				function()
					require("rulebook").lookupRule()
				end,
				desc = "Look up diagnostic rule",
			},
			{
				"<leader>ry",
				function()
					require("rulebook").yankDiagnosticCode()
				end,
				desc = "Yank diagnostic code",
			},
			{
				"<leader>rs",
				function()
					require("rulebook").suppressFormatter()
				end,
				desc = "Suppress formatter",
			},
		},
	},
	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

	{
		"saadparwaiz1/cmp_luasnip",
		dependencies = { "nvim-cmp" },
	},
	{
		"hrsh7th/cmp-buffer",
		dependencies = { "hrsh7th/nvim-cmp" },
	},
	{
		"hrsh7th/cmp-nvim-lsp",
		dependencies = { "hrsh7th/nvim-cmp" },
	},
	{
		"hrsh7th/cmp-path",
		dependencies = { "hrsh7th/nvim-cmp" },
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"cmp-buffer",
			"cmp-path",
			"cmp-nvim-lsp",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
	},
	{
		"declancm/cinnamon.nvim",
	},
	{
		"andweeb/presence.nvim",
		config = function()
			require("presence").setup({
				log_level = nil,

				auto_update = true,
				neovim_image_text = "The One True Text Editor",
				main_image = "neovim",
				show_time = true,

				-- Don’t show sidebars/utility buffers
				blacklist = {
					"NvimTree",
					"TelescopePrompt",
					"lazy",
					"mason",
					"harpoon",
					"alpha",
				},

				-- Customize the text it shows
				editing_text = "Editing %s",
				file_explorer_text = "Browsing %s",
				reading_text = "Reading %s",
				workspace_text = "Working on %s",

				-- Optional: add a GitHub button when in a git repo
				buttons = true,
			})
		end,
	},
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		config = function()
			require("dashboard").setup({})
		end,
		dependencies = { { "nvim-tree/nvim-web-devicons" } },
	},
	{
		"kdheepak/lazygit.nvim",
		lazy = false,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = { "nvim-lua/plenary.nvim" },
	}, -- Comment.nvim plugin for easy commenting
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	{ -- TODO: https://github.com/MunifTanjim/nougat.nvim/blob/main/examples/bubbly.lua
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({})
		end,
	}, -- which-key.nvim - helps you remember key bindings
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({
						global = false,
					})
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	}, -- Treesitter and related plugins
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"javascript",
					"typescript",
					"python",
					"html",
					"css",
					"json",
					"yaml",
					"bash",
					"markdown",
					"markdown_inline",
				},
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true,
				},
			})
		end,
	}, -- nvim-treesitter-context - keeps current scope info pinned at the top of the window
	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			enable = true,
			max_lines = 4,
		},
	}, -- log-highlight.nvim - adds syntax highlighting for log files
	{
		"fei6409/log-highlight.nvim",
		config = function()
			require("log-highlight").setup({})
		end,
	}, -- nvim-colorizer.lua - adds inline color previews
	{
		"NvChad/nvim-colorizer.lua",
		lazy = false,
		event = "BufReadPre",
		opts = {
			filetypes = { "*" },
			user_default_options = {
				RGB = true,
				RRGGBB = true,
				names = true,
				RRGGBBAA = false,
				css = true,
				css_fn = true,
			},
		},
	}, -- document-color.nvim - uses LSP's color provider
	{
		"mrshmllow/document-color.nvim",
		lazy = false,
		ft = { "css", "scss", "html", "javascript", "typescript" },
		config = function()
			require("document-color").setup({
				mode = "single",
			})
		end,
	}, -- nvim-treesitter-refactor - enhances TS with refactoring queries
	{
		"nvim-treesitter/nvim-treesitter-refactor",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter.configs").setup({
				refactor = {
					highlight_definitions = {
						enable = true,
					},
				},
			})
		end,
	}, -- toggleterm.nvim - better terminal integration
	{
		"akinsho/toggleterm.nvim",
		opts = {
			size = 20,
			open_mapping = [[<c-\>]],
			direction = "float",
		},
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
	-- Harpoon - quick file navigation and marking
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup({
				settings = {
					save_on_toggle = true,
					sync_on_ui_close = true,
					save_on_change = true,
					enter_on_sendcmd = false,
					tmux_autoclose_windows = false,
					excluded_filetypes = {
						"harpoon",
						"alpha",
						"dashboard",
						"gitcommit",
					},
					mark_branch = false,
				},
			})
		end,
	}, -- vim-eunuch - UNIX shell helpers
	{
		"tpope/vim-eunuch",
		lazy = false,
		cmd = {
			"Remove", -- :Remove → delete file + buffer
			"Rename", -- :Rename old new
			"Move", -- :Move old new (same as Rename)
			"Chmod", -- :Chmod +x foo.sh
			"Mkdir", -- :Mkdir path/to/dir
			"SudoWrite", -- :SudoWrite → write buffer via sudo
			"SudoEdit", -- :SudoEdit → edit file via sudo
			"Delete", -- :Delete → delete file from disk
			"Copy", -- :Copy → copy file
			"Duplicate", -- :Duplicate → duplicate file
			"Find", -- :Find → find files
			"Locate", -- :Locate → locate files
			"Wall", -- :Wall → write all windows
		},
	},
	-- vim-surround - surround text objects with brackets, quotes, etc.
	{
		"tpope/vim-surround",
		lazy = false,
		keys = {
			{ "ys", mode = "n", desc = "Add surrounding" },
			{ "cs", mode = "n", desc = "Change surrounding" },
			{ "ds", mode = "n", desc = "Delete surrounding" },
			{ "S",  mode = "v", desc = "Surround selection" },
		},
	},
	{
		"jay-babu/mason-null-ls.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim", -- null-ls fork you already use
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = {
					"stylua",
					"black",
					"flake8",
					"prettier",
					"gofumpt",
					"goimports",
					"rustfmt",
					"ruff",
				},
				automatic_installation = true,
			})
		end,
	},
})
