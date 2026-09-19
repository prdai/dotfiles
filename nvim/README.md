# Neovim Config

**Leader**: `<Space>` &nbsp;|&nbsp; **Local leader**: `,`

> **Fresh machine setup:** lazy.nvim is not auto-installed. Run this once before opening nvim:
> ```bash
> git clone --filter=blob:none https://github.com/folke/lazy.nvim.git \
>   --branch=stable ~/.local/share/nvim/lazy/lazy.nvim
> ```

---

## Global Keymaps

### Files & Explorer

| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader><leader>` | Toggle to alternate (last) file |
| `<leader>ee` | Toggle file explorer (nvim-tree) |
| `<leader>ef` | Reveal current file in explorer |
| `<leader>rm` | Delete current file from disk |
| `<leader>rn` | Rename current file |
| `<leader>md` | Create directory |
| `<leader>ww` | Write file with sudo |

### Splits

| Key | Action |
|-----|--------|
| `<leader>sv` | Vertical split |
| `<leader>sh` | Horizontal split |
| `<leader>se` | Equalise split sizes |
| `<leader>sx` | Close current split |

### Window Navigation

| Key | Action |
|-----|--------|
| `<C-h>` | Focus window left |
| `<C-j>` | Focus window down |
| `<C-k>` | Focus window up |
| `<C-l>` | Focus window right |

Works in both **normal** and **terminal** mode.

### Terminal

| Key | Action |
|-----|--------|
| `<C-\>` | Toggle floating terminal |

### Search

| Key | Action |
|-----|--------|
| `<Esc>` | Clear search highlight |

### Paste

| Key | Mode | Action |
|-----|------|--------|
| `,p` | Normal | Paste last yanked (register `0`, ignores deletes) |
| `p` | Visual | Paste over selection without yanking it |

---

## File Finder (fff.nvim)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |

**Inside fff picker:**

| Key | Action |
|-----|--------|
| `<CR>` | Open file |
| `<C-s>` | Open in horizontal split |
| `<C-v>` | Open in vertical split |
| `<C-t>` | Open in new tab |
| `<Tab>` | Toggle multi-select |
| `<S-Tab>` | Cycle grep mode (text / regex / fuzzy) |
| `<C-q>` | Send selection to quickfix |

---

## Harpoon

| Key | Action |
|-----|--------|
| `<leader>ha` | Add current file |
| `<leader>hh` | Open quick menu |
| `<leader>h1` | Jump to file 1 |
| `<leader>h2` | Jump to file 2 |
| `<leader>h3` | Jump to file 3 |
| `<leader>h4` | Jump to file 4 |
| `<leader>hp` | Previous file |
| `<leader>hn` | Next file |

---

## LSP (buffer-local, active when LSP attaches)

### Navigation

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Find all references (opens quickfix) |

### Hover & Help

| Key | Action |
|-----|--------|
| `K` | Hover documentation |
| `<leader>k` | Signature help |
| `<leader>of` | Open diagnostic float |

### Actions

| Key | Action |
|-----|--------|
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>D` | Type definition |
| `<leader>fo` | Format buffer — Ruff on Python, LSP elsewhere |
| `<leader>ch` | Switch source/header (C/C++) |

### Language Servers

| Language | Server |
|----------|--------|
| Python | `basedpyright` + `ruff` (type checking off; pyright diagnostics suppressed) |
| TypeScript / JS | `ts_ls` |
| Go | `gopls` (gofumpt, staticcheck) |
| Rust | `rust_analyzer` |
| Lua | `lua_ls` |
| Terraform | `terraformls` |
| C / C++ | `clangd` (+ clangd_extensions) |
| Bash | `bashls` |

---

## Diagnostics

### Trouble

| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle workspace diagnostics |
| `<leader>xX` | Toggle buffer diagnostics |
| `<leader>cs` | Symbols panel |
| `<leader>cl` | LSP definitions / references panel |
| `<leader>xL` | Location list |
| `<leader>xQ` | Quickfix list |

### Built-in navigation

| Key | Action |
|-----|--------|
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>of` | Floating diagnostic detail |

---

## Git

| Key | Action |
|-----|--------|
| `<leader>lg` | Open LazyGit |
| `<leader>gb` | Toggle git blame window (blame.nvim) |
| `<leader>gB` | Toggle inline virtual-text blame |

Inline virtual-text blame is enabled by default on startup.

---

## Diagnostic Rules (nvim-rulebook)

| Key | Action |
|-----|--------|
| `<leader>ri` | Ignore diagnostic rule (add inline comment) |
| `<leader>rl` | Look up rule in browser |
| `<leader>ry` | Yank diagnostic code |
| `<leader>rs` | Suppress formatter for line |

---

## Completion (nvim-cmp, insert mode)

| Key | Action |
|-----|--------|
| `<Tab>` | Next item / jump forward in snippet |
| `<S-Tab>` | Previous item / jump back in snippet |
| `<CR>` | Confirm selection |
| `<C-Space>` | Force open completion menu |
| `<C-e>` | Abort / close menu |
| `<C-b>` | Scroll docs up |
| `<C-f>` | Scroll docs down |

---

## Surround (vim-surround)

| Key | Mode | Action |
|-----|------|--------|
| `ys{motion}{char}` | Normal | Add surround — e.g. `ysiw"` wraps word in `"` |
| `cs{old}{new}` | Normal | Change surround — e.g. `cs"'` changes `"` to `'` |
| `ds{char}` | Normal | Delete surround — e.g. `ds"` removes `"` |
| `S{char}` | Visual | Surround selection |

---

## Comments (Comment.nvim)

| Key | Mode | Action |
|-----|------|--------|
| `gcc` | Normal | Toggle line comment |
| `gc{motion}` | Normal | Toggle comment over motion |
| `gbc` | Normal | Toggle block comment |
| `gc` | Visual | Toggle comment on selection |

---

## Misc

| Key | Action |
|-----|--------|
| `<leader>?` | Show buffer-local keymaps (which-key) |

---

## Tips

- References (`gr`) open in quickfix — view with `<leader>xx` or `:copen`
- Format on save is **off** — use `<leader>fo` manually
- Formatters: stylua (Lua), prettier (JS/TS/HTML/CSS), gofumpt+goimports (Go), clang-format (C/C++), Ruff (Python)
- C/C++: generate `compile_commands.json` so clangd resolves includes — `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .` or `bear -- make`; clang-format reads project `.clang-format` and falls back to LLVM style
