# dotfiles

my personal dev configs for arch + macos.

## setup

```bash
git clone https://github.com/prdai/dotfiles.git ~/.dotfiles

# shell
ln -sf ~/.dotfiles/bash/bashrc ~/.bashrc                  # arch linux / bash
ln -sf ~/.dotfiles/fish ~/.config/fish                    # fish shell
ln -sf ~/.dotfiles/zshrc/.zshrc ~/.zshrc                  # macos / zsh

# editors + tools
ln -sf ~/.dotfiles/nvim ~/.config/
ln -sf ~/.dotfiles/lazygit ~/.config/
ln -sf ~/.dotfiles/opencode ~/.config/
ln -sf ~/.dotfiles/.idea/.ideavimrc ~/.ideavimrc
ln -sf ~/.dotfiles/.idea/.editorconfig ~/.editorconfig

# terminals
ln -sf ~/.dotfiles/ghostty ~/.config/
ln -sf ~/.dotfiles/kitty ~/.config/

# multiplexer
ln -sf ~/.dotfiles/tmux ~/.config/

# linux desktop stack (hyprland / omarchy)
ln -sf ~/.dotfiles/hypr ~/.config/
ln -sf ~/.dotfiles/waybar ~/.config/
ln -sf ~/.dotfiles/swaync ~/.config/
ln -sf ~/.dotfiles/vicinae ~/.config/
ln -sf ~/.dotfiles/btop ~/.config/

# macos window manager
ln -sf ~/.dotfiles/aerospace ~/.config/

# git
ln -sf ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/git/ignore ~/.config/git/ignore

# agent rules + skills (opencode, pi): global skills symlinked from agents/skills/
for s in ~/.dotfiles/agents/skills/*/; do
  ln -sfn "${s%/}" ~/.agents/skills/"$(basename "$s")"
done

# t3 code desktop config (app + launcher: see t3code/README.md)
cp ~/.dotfiles/t3code/userdata/*.json ~/.t3/userdata/

# reload shell
source ~/.bashrc   # or: source ~/.zshrc
```

## what's inside

| path | purpose |
|------|---------|
| `aerospace/` | aerospace tiling window manager config for macos |
| `agents/` | shared agent rules (AGENTS.md) + vendored skills, referenced by opencode, pi, and T3 Code |
| `bash/` | bash config, aliases, prompt, helper functions |
| `btop/` | btop system monitor config |
| `fish/` | fish environment setup snippets |
| `ghostty/` | primary terminal emulator config |
| `git/` | global git config + global ignore |
| `hypr/` | hyprland overrides layered on omarchy defaults |
| `kitty/` | alternate terminal emulator config |
| `lazygit/` | lazygit config + custom commit keybinding |
| `nvim/` | neovim config (lsp, keymaps, plugins) |
| `obsidian/` | obsidian vimrc settings |
| `opencode/` | opencode agentic CLI/TUI config + codex desktop theme |
| `scripts/` | utility scripts (currently obsidian vault sync) |
| `swaync/` | sway notification center config/theme/icons |
| `systemd/` | user services (currently obsidian sync service) |
| `t3code/` | T3 Code desktop config + AppImage launcher templates |
| `tmux/` | tmux config + plugin setup |
| `vicinae/` | vicinae launcher config |
| `wallpapers/` | wallpaper assets |
| `waybar/` | waybar modules + styling |
| `wezterm/` | archived terminal config (kept for reference) |
| `zshrc/` | zsh config, aliases, prompt, helper functions |
| `.idea/` | ideavim/editorconfig for jetbrains |
| `.vscode/` | vscode settings + vim-aligned keybinding notes |

> **note:** wezterm config is no longer maintained. ghostty is the active terminal setup.

check each `*/README.md` for directory-specific notes.

for contribution workflow and docs tone, see [`CONTRIBUTING.md`](./CONTRIBUTING.md).
