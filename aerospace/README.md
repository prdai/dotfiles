# aerospace

tiling window manager for macos.

## setup

get the app bundle id for window rules:
```bash
cd /Applications && mdls -name kMDItemCFBundleIdentifier "AppName.app"
```

## key bindings

**windows**
- `Alt+Arrow` → Focus window left/down/up/right
- `Alt+Shift+Arrow` → Move window left/down/up/right
- `Alt+f` → Fullscreen toggle
- `Alt+Shift+minus/equal` → Resize smart -50/+50

**layout**
- `Alt+/` → Toggle tiles (horizontal/vertical)
- `Alt+,` → Toggle accordion (horizontal/vertical)

**workspaces**
- `Alt+1-9` → Switch to workspace 1-9
- `Alt+Shift+1-9` → Move window to workspace 1-9
- `Alt+Tab` → Toggle last workspace
- `Alt+Shift+Tab` → Focus next window (DFS)

**service mode** (`Alt+Shift+;`)
- `Esc` → Reload config and exit service mode
- `r` → Flatten/reset layout
- `f` → Toggle floating/tiling
- `Backspace` → Close all windows except current
- `Alt+Shift+Arrow` → Join container left/down/up/right

**other**
- `Alt+t` → Open new Ghostty terminal
- `Alt+Shift+c` → Reload config

## workspace assignments

| Workspace | App |
|-----------|-----|
| 1 | Ghostty (terminal) |
| 2 | Zen Browser |
| 3 | Obsidian |
| 4 | T3 Code |
| 5 | Calendar |
| 7 | Spotify |
| 8 | Slack |
| 9 | WhatsApp |

Workspaces are not pinned to a display; they open on the monitor in use.

## features

- Window borders via `borders` (active: white, inactive: dark)
- Gaps: 10px inner + 10px outer
- Accordion padding: 30px
- Auto-start at login
