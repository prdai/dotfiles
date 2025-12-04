# Neovim Configuration

## Key Bindings

**Leader**: `<space>`
**Escape ReMap**: `<capslock>`

```
setxkbmap -option caps:swapescape
```

### Essential

- `<leader>w` → Save file
- `<leader>?` → Show buffer local keymaps
- `<Esc>` → Clear search highlighting

### File Explorer

- `<leader>ee` → Toggle file explorer
- `<leader>ef` → Toggle file explorer on current file

### Search & Find

- `<leader>ff` → Find files
- `<leader>fg` → Live grep (search in files)
- `<leader>fb` → Find buffers
- `<leader>fh` → Find help tags
- `<leader>/` → Search current file (fuzzy)

### Window Management

**Splits:**

- `<leader>sv` → Split window vertically
- `<leader>sh` → Split window horizontally
- `<leader>se` → Make splits equal size
- `<leader>sx` → Close current split
- `<leader>+` → Increase split height
- `<leader>-` → Decrease split height
- `<leader>>` → Increase split width
- `<leader><` → Decrease split width

**Tabs:**

- `<leader>to` → Open new tab
- `<leader>tx` → Close current tab
- `<leader>tn` → Go to next tab
- `<leader>tp` → Go to previous tab
- `<leader>tf` → Open current buffer in new tab

**Navigation:**

- `<C-Space>` → Navigate to next Tmux pane

### Terminal

- `<C-\>` → Toggle floating terminal (Normal mode)
- `<C-\>` → Toggle floating terminal (Terminal mode)

### Git

- `<leader>lg` → Open LazyGit

### Harpoon (Quick File Navigation)

- `<leader>ha` → Add file to Harpoon
- `<leader>hh` → Toggle Harpoon menu
- `<leader>h1` → Jump to Harpoon file 1
- `<leader>h2` → Jump to Harpoon file 2
- `<leader>h3` → Jump to Harpoon file 3
- `<leader>h4` → Jump to Harpoon file 4
- `<leader>hp` → Go to previous Harpoon file
- `<leader>hn` → Go to next Harpoon file

### Completion

- `<C-b>` → Scroll documentation backward
- `<C-f>` → Scroll documentation forward
- `<C-Space>` → Trigger completion
- `<C-e>` → Abort completion
- `<CR>` → Confirm completion
- `<Tab>` → Select next item / expand snippet
- `<S-Tab>` → Select previous item / jump back in snippet

### LSP

**Core Navigation:**

- `gd` → Go to definition
- `gD` → Go to declaration
- `gr` → Find references
- `gi` → Go to implementation
- `K` → Show documentation (hover)
- `<C-k>` → Show signature help
- `<space>D` → Go to type definition

**LSP Actions:**

- `<leader>ca` / `<space>ca` → Code actions
- `<space>rn` → Rename symbol
- `<space>fo` → Format code
- `<leader>of` → Open floating diagnostic window

**LSP Telescope Integration:**

- `<leader>fd` → Find LSP definitions
- `<leader>fr` → Find LSP references
- `<leader>fi` → Find LSP implementations
- `<leader>fs` → Find document symbols
- `<leader>fS` → Find workspace symbols

### Trouble (Diagnostics)

- `<leader>xx` → Toggle diagnostics
- `<leader>xX` → Toggle buffer diagnostics
- `<leader>cs` → Toggle symbols
- `<leader>cl` → Toggle LSP definitions/references
- `<leader>xL` → Toggle location list
- `<leader>xQ` → Toggle quickfix list

### Surround

- `ys` → Add surrounding
- `cs` → Change surrounding
- `ds` → Delete surrounding
- `S` → Surround selection (visual mode)

### File Operations

- `<leader>rm` → Delete current file
- `<leader>rn` → Rename current file
- `<leader>md` → Create directory
- `<leader>ww` → Write file with sudo
