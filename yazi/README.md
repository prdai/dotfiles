# yazi

Config for [yazi](https://github.com/sxyazi/yazi), the terminal file manager. Four plugins are vendored here so the setup does not depend on network access, and the flexoki-dark flavor is pinned through `ya pkg`.

## install

```bash
sudo pacman -S yazi 7zip resvg
ln -sf ~/.dotfiles/yazi ~/.config/yazi
```

`file` is pulled in by the package. `ffmpeg`, `jq`, `poppler`, `fd`, `ripgrep`, `fzf`, `zoxide`, `imagemagick`, and `wl-clipboard` are already installed and enable video, JSON, PDF, search, and clipboard previews.

## layout

| path | purpose |
|------|---------|
| `yazi.toml` | sorting, hidden files, linemode, preview limits, git fetchers |
| `keymap.toml` | `l` and `<Enter>` smart enter, `f` jump to char |
| `theme.toml` | selects the flexoki-dark flavor |
| `init.lua` | enables full-border and git, defines the `size_and_mtime` linemode |
| `package.toml` | tracks the flavor for `ya pkg` |
| `plugins/` | vendored plugins, see below |
| `flavors/flexoki-dark.yazi/` | flavor installed by `ya pkg` |

## keys

Only the additions and the most used defaults are listed. Press `?` for the full keymap.

| Key | Action |
|-----|--------|
| `l`, `<Enter>` | Enter the directory or open the file (smart-enter) |
| `f` | Jump to the next file starting with a char |
| `h` | Go to the parent directory |
| `.` | Toggle hidden files |
| `<Space>` | Select the hovered file |
| `y` / `x` / `p` | Yank, cut, paste |
| `d` | Trash the selection |
| `a` | Create a file or directory |
| `r` | Rename |
| `/` | Filter the current directory |
| `s` | Search by name with `fd` |
| `S` | Search contents with `ripgrep` |
| `z` | Jump with `zoxide` |
| `~`, `g` `h` | Home, open the help menu |
| `q` | Quit, `Q` quits without writing the cwd file |

## plugins

Vendored from [yazi-rs/plugins](https://github.com/yazi-rs/plugins) at `e0bbd20`. Update by re-copying the directories and bumping the hash here.

| Plugin | Purpose |
|--------|---------|
| `full-border` | rounded border around every pane |
| `git` | git status signs in the linemode |
| `smart-enter` | one key to enter directories or open files |
| `jump-to-char` | vim-like `f<char>` navigation |

## flavor

Installed with `ya pkg add gosxrgxx/flexoki-dark` and pinned in `package.toml` at rev `649e569`. Refresh it with `ya pkg upgrade`.

`theme.toml` only sets the dark flavor. Add a `light` flavor if automatic light mode is ever wanted.

## shell wrapper

`y` in `bash/bashrc` runs yazi and changes the shell directory to wherever yazi exited:

```bash
y() {
	local tmp cwd
	tmp="$(mktemp -t yazi-cwd.XXXXXX)"
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd <"$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
```

## desktop binding

`SUPER + SHIFT + F` launches `yazi` in the default terminal through `omarchy-launch-or-focus-tui`, so pressing it again focuses the existing window instead of opening a second one. The binding lives in `hypr/bindings.lua`.
