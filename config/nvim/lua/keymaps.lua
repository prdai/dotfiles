vim.g.mapleader = " "

-- Basic File Operations
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", {
	desc = "Save",
})

-- File Explorer (nvim-tree)
vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", {
	desc = "Toggle file explorer",
})
vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", {
	desc = "Toggle file explorer on current file",
})

-- Split Window Management
-- Create splits
vim.keymap.set("n", "<leader>sv", "<C-w>v", {
	desc = "Split window vertically",
})
vim.keymap.set("n", "<leader>sh", "<C-w>s", {
	desc = "Split window horizontally",
})
vim.keymap.set("n", "<leader>se", "<C-w>=", {
	desc = "Make splits equal size",
})
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", {
	desc = "Close current split",
})

-- Resize splits
vim.keymap.set("n", "<leader>+", "<C-w>+", {
	desc = "Increase split height",
})
vim.keymap.set("n", "<leader>-", "<C-w>-", {
	desc = "Decrease split height",
})
vim.keymap.set("n", "<leader>>", "<C-w>>", {
	desc = "Increase split width",
})
vim.keymap.set("n", "<leader><", "<C-w><", {
	desc = "Decrease split width",
})

-- System Clipboard Integration
vim.keymap.set({ "n", "v" }, "y", "y", {
	desc = "Copy to system clipboard",
})
vim.keymap.set({ "n", "v" }, "p", "p", {
	desc = "Paste from system clipboard",
})

-- Git Integration (LazyGit)
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<cr>", {
	desc = "Open LazyGit",
})

-- Clear search highlighting
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", {
	desc = "Clear search highlighting",
})

-- Comments
-- Note: Comment.nvim setup is handled in plugins.lua
-- These keymaps will work once the plugin is loaded
-- Enhanced file search with <leader>/ (like Ctrl+F in other editors)
vim.keymap.set("n", "<leader>/", function()
	require("telescope.builtin").current_buffer_fuzzy_find()
end, {
	desc = "Search within current file (fuzzy)",
})

-- Harpoon (Quick File Navigation)
vim.keymap.set("n", "<leader>ha", function()
	require("harpoon"):list():add()
end, {
	desc = "Harpoon add file",
})

vim.keymap.set("n", "<leader>hh", function()
	local harpoon = require("harpoon")
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, {
	desc = "Harpoon toggle menu",
})

-- Navigate to specific harpoon marks
vim.keymap.set("n", "<leader>h1", function()
	require("harpoon"):list():select(1)
end, {
	desc = "Harpoon file 1",
})

vim.keymap.set("n", "<leader>h2", function()
	require("harpoon"):list():select(2)
end, {
	desc = "Harpoon file 2",
})

vim.keymap.set("n", "<leader>h3", function()
	require("harpoon"):list():select(3)
end, {
	desc = "Harpoon file 3",
})

vim.keymap.set("n", "<leader>h4", function()
	require("harpoon"):list():select(4)
end, {
	desc = "Harpoon file 4",
})

-- Harpoon navigation with arrow-like keys (alternative to numbers)
vim.keymap.set("n", "<leader>hp", function()
	require("harpoon"):list():prev()
end, {
	desc = "Harpoon previous",
})

vim.keymap.set("n", "<leader>hn", function()
	require("harpoon"):list():next()
end, {
	desc = "Harpoon next",
})

-- LSP Enhanced Telescope Integration
-- Add LSP-specific telescope keymaps that work when LSP is attached
vim.keymap.set("n", "<leader>fd", function()
	require("telescope.builtin").lsp_definitions()
end, {
	desc = "Find LSP definitions",
})

vim.keymap.set("n", "<leader>fr", function()
	require("telescope.builtin").lsp_references()
end, {
	desc = "Find LSP references",
})

vim.keymap.set("n", "<leader>fi", function()
	require("telescope.builtin").lsp_implementations()
end, {
	desc = "Find LSP implementations",
})

vim.keymap.set("n", "<leader>fs", function()
	require("telescope.builtin").lsp_document_symbols()
end, {
	desc = "Find document symbols",
})

vim.keymap.set("n", "<leader>fS", function()
	require("telescope.builtin").lsp_workspace_symbols()
end, {
	desc = "Find workspace symbols",
})

vim.keymap.set("n", ",p", '"0p', { desc = "[P]aste last yanked not deleted" })
vim.keymap.set(
	"x",
	"p",
	'"_dP',
	{ desc = "[P]aste over selected without saving to register" }
)

-- ═══════════════════════════════════════════════════════════════════════════
-- Terminal Integration
-- ═══════════════════════════════════════════════════════════════════════════
vim.keymap.set("n", "<C-\\>", "<cmd>ToggleTerm direction=float<CR>", {
	desc = "Toggle floating terminal",
})

vim.keymap.set("t", "<C-\\>", "<C-\\><C-n><cmd>ToggleTerm<CR>", {
	desc = "Toggle floating terminal from terminal mode",
})

-- ═══════════════════════════════════════════════════════════════════════════
-- Eunuch (UNIX helpers) - Optional Keymappings
-- ═══════════════════════════════════════════════════════════════════════════
vim.keymap.set("n", "<leader>rm", "<cmd>Remove %<CR>", {
	desc = "Remove current file",
})

vim.keymap.set("n", "<leader>rn", function()
	local current_file = vim.fn.expand("%:t")
	vim.ui.input({
		prompt = "Rename to: ",
		default = current_file,
	}, function(new_name)
		if new_name and new_name ~= "" and new_name ~= current_file then
			vim.cmd("Rename " .. vim.fn.shellescape(new_name))
		end
	end)
end, {
	desc = "Rename current file",
})

vim.keymap.set("n", "<leader>md", function()
	vim.ui.input({
		prompt = "Create directory: ",
		default = vim.fn.expand("%:p:h") .. "/",
	}, function(dir_name)
		if dir_name and dir_name ~= "" then
			vim.cmd("Mkdir " .. vim.fn.shellescape(dir_name))
		end
	end)
end, {
	desc = "Create directory",
})

vim.keymap.set("n", "<leader>ww", "<cmd>SudoWrite<CR>", {
	desc = "Write file with sudo",
})

vim.keymap.set(
	"n",
	"<C-S-h>",
	"<C-w><C-h>",
	{ desc = "Move focus to the left window" }
)
vim.keymap.set(
	"n",
	"<C-S-l>",
	"<C-w><C-l>",
	{ desc = "Move focus to the right window" }
)
vim.keymap.set(
	"n",
	"<C-S-j>",
	"<C-w><C-j>",
	{ desc = "Move focus to the lower window" }
)
vim.keymap.set(
	"n",
	"<C-S-k>",
	"<C-w><C-k>",
	{ desc = "Move focus to the upper window" }
)

vim.keymap.set(
	"n",
	"<C-h>",
	"<C-w><C-h>",
	{ desc = "Move focus to the left window" }
)
vim.keymap.set(
	"n",
	"<C-l>",
	"<C-w><C-l>",
	{ desc = "Move focus to the right window" }
)
vim.keymap.set(
	"n",
	"<C-j>",
	"<C-w><C-j>",
	{ desc = "Move focus to the lower window" }
)
vim.keymap.set(
	"n",
	"<C-k>",
	"<C-w><C-k>",
	{ desc = "Move focus to the upper window" }
)

vim.keymap.set(
	"t",
	"<C-h>",
	[[<C-\><C-n><C-w>h]],
	{ desc = "Move focus to the left window" }
)
vim.keymap.set(
	"t",
	"<C-l>",
	[[<C-\><C-n><C-w>l]],
	{ desc = "Move focus to the right window" }
)
vim.keymap.set(
	"t",
	"<C-j>",
	[[<C-\><C-n><C-w>j]],
	{ desc = "Move focus to the lower window" }
)
vim.keymap.set(
	"t",
	"<C-k>",
	[[<C-\><C-n><C-w>k]],
	{ desc = "Move focus to the upper window" }
)
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
