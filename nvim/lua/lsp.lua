require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

require("mason-lspconfig").setup({
	ensure_installed = {
		"basedpyright",
		"lua_ls",
		"rust_analyzer",
		"ts_ls",
		"gopls",
		"terraformls",
		"ruff",
		"clangd",
		"protols",
		"dockerls",
		"docker_compose_language_service",
		"r_language_server",
	},
	automatic_installation = true,
})

local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities = ok and cmp_nvim_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()
capabilities.offsetEncoding = { "utf-16" }

-- Diagnostics (single source of truth — merged from former diagnostics.lua)
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
	virtual_text = {
		prefix = "●",
		spacing = 2,
		source = "if_many",
		format = function(diagnostic)
			if diagnostic.source == "pyright" or diagnostic.source == "basedpyright" then
				return nil
			end
			if diagnostic.source == "ruff" then
				return string.format("%s [%s]", diagnostic.message, diagnostic.code or "")
			end
			return diagnostic.message
		end,
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

-- Suppress basedpyright/pyright diagnostics — ruff handles linting
local orig_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
	if result and result.diagnostics then
		local client = vim.lsp.get_client_by_id(ctx.client_id)
		if client and (client.name == "basedpyright" or client.name == "pyright") then
			result.diagnostics = {}
		end
	end
	orig_handler(err, result, ctx, config)
end

local function center() vim.schedule(function() vim.cmd("normal! zz") end) end

local on_attach = function(_, bufnr)
	vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
	local opts = { noremap = true, silent = true, buffer = bufnr }
	local ext = function(desc) return vim.tbl_extend("force", opts, { desc = desc }) end

	-- Navigation (go-to via built-in LSP, no telescope dependency)
	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition(); center() end, ext("LSP: Definition"))
	vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration(); center() end, ext("LSP: Declaration"))
	vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, ext("LSP: Implementation"))
	vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, ext("LSP: References"))

	-- Actions
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, ext("LSP: Code action"))
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, ext("LSP: Rename"))
	vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, ext("LSP: Type definition"))

	-- Hover / diagnostics
	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover()
		vim.cmd("wincmd p")
	end, { silent = true })
	vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, ext("LSP: Signature help"))
	vim.keymap.set("n", "<leader>of", vim.diagnostic.open_float, ext("LSP: Open diagnostic float"))

	-- Manual format: Ruff on Python, LSP elsewhere
	vim.keymap.set("n", "<leader>fo", function()
		if vim.bo[bufnr].filetype == "python" then
			vim.cmd("RuffFixFile")
		else
			vim.lsp.buf.format({ async = true })
		end
	end, ext("Format buffer"))
end

-- ─── Server configs ──────────────────────────────────────────────────────────

vim.lsp.config.ruff = {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_markers = { "ruff.toml", ".ruff.toml", "pyproject.toml", "setup.py", ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
}
vim.lsp.enable("ruff")

vim.lsp.config.basedpyright = {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyrightconfig.json", "pyproject.toml", "setup.py", ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "off",
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
			},
		},
		python = {
			analysis = {
				typeCheckingMode = "off",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
}
vim.lsp.enable("basedpyright")

vim.lsp.config.ts_ls = {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
}
vim.lsp.enable("ts_ls")

local home = os.getenv("HOME")
vim.lsp.config.gopls = {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.mod", "go.work", ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
	init_options = { usePlaceholders = true, completeUnimported = true },
	settings = {
		gopls = {
			gofumpt = true,
			analyses = { unusedparams = true },
			staticcheck = true,
			["build.directoryFilters"] = { "-node_modules" },
		},
	},
}
vim.lsp.enable("gopls")

vim.lsp.config.rust_analyzer = {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		["rust-analyzer"] = {
			checkOnSave = true,
			cargo = { features = { "server" } },
		},
	},
}
vim.lsp.enable("rust_analyzer")

vim.lsp.config.lua_ls = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = { library = vim.api.nvim_get_runtime_file("", true) },
			telemetry = { enable = false },
		},
	},
}
vim.lsp.enable("lua_ls")

vim.lsp.config.terraformls = {
	cmd = { "terraform-ls", "serve" },
	filetypes = { "terraform", "tf", "hcl" },
	capabilities = capabilities,
	on_attach = on_attach,
}
vim.lsp.enable("terraformls")

vim.lsp.config.clangd = {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--fallback-style=llvm",
	},
	filetypes = { "c", "cpp", "objc", "objcpp" },
	root_markers = {
		"compile_commands.json",
		"compile_flags.txt",
		"CMakeLists.txt",
		"Makefile",
		".clangd",
		".clang-tidy",
		".clang-format",
		".git",
	},
	capabilities = capabilities,
	init_options = { usePlaceholders = true, completeUnimported = true, clangdFileStatus = true },
	-- clang-format (none-ls) owns formatting; without this clangd formats too and both run
	on_init = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
	on_attach = on_attach,
}
vim.lsp.enable("clangd")

-- Ballerina LS ships with the local `bal` distribution (not managed by mason)
vim.lsp.config.ballerina = {
	cmd = { "bal", "start-language-server" },
	filetypes = { "ballerina" },
	root_markers = { "Ballerina.toml", ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
}
vim.lsp.enable("ballerina")

-- Dockerfile LSP (dockerfile-language-server-nodejs)
vim.lsp.config.dockerls = {
	cmd = { "docker-langserver", "--stdio" },
	filetypes = { "dockerfile" },
	root_markers = { "Dockerfile", ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
}
vim.lsp.enable("dockerls")

-- Docker Compose LSP (attaches to compose files detected as yaml.docker-compose)
vim.lsp.config.docker_compose_language_service = {
	cmd = { "docker-compose-langserver", "--stdio" },
	filetypes = { "yaml.docker-compose" },
	root_markers = { "docker-compose.yaml", "docker-compose.yml", "compose.yaml", "compose.yml", ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
}
vim.lsp.enable("docker_compose_language_service")

-- Detect docker-compose files so the compose LSP attaches (yaml LSP would otherwise grab them)
vim.filetype.add({
	pattern = {
		["[Dd]ocker%-?[Cc]ompose.*%.ya?ml"] = "yaml.docker-compose",
		["[Cc]ompose.*%.ya?ml"] = "yaml.docker-compose",
	},
})

-- R LSP (r_language_server, installed via Mason; requires the R `languageserver` package)
vim.lsp.config.r_language_server = {
	cmd = { "R", "--no-echo", "-e", "languageserver::run()" },
	filetypes = { "r", "rmd" },
	root_markers = { ".Rproj", "DESCRIPTION", ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
}
vim.lsp.enable("r_language_server")

-- Julia LSP (LanguageServer.jl; not Mason-managed — installed via Julia's package manager)
vim.lsp.config.julials = {
	cmd = { "julia", "--startup-file=no", "--history-file=no", "-e",
		[[using LanguageServer; runserver()]] },
	filetypes = { "julia" },
	root_markers = { "Project.toml", "JuliaProject.toml", ".git" },
	capabilities = capabilities,
	on_attach = on_attach,
}
vim.lsp.enable("julials")

vim.lsp.enable("bashls")

vim.lsp.enable("protols")
