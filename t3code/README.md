# t3code

config for [T3 Code](https://github.com/pingdotgg/t3code), the desktop GUI for AI coding agents.

## why the launcher exists

T3 Code ships as an AppImage, which needs `libfuse.so.2`. Ubuntu 24.04 ships
fuse3 only, so launching the AppImage directly fails with
`dlopen(): error loading libfuse.so.2`. The desktop entries here run it with
`APPIMAGE_EXTRACT_AND_RUN=1`, which extracts to a temp dir and runs without FUSE.

## app install

Get an AppImage from the releases page (or `yay -S t3code-bin` on arch) and put
it at `~/Applications/t3code.AppImage`. The desktop entries are templates:
substitute `__T3_APPIMAGE__` and `__T3_ICON__`, then copy them into
`~/.local/share/applications/`:

```bash
app="$HOME/Applications/t3code.AppImage"
icon="$HOME/.local/share/icons/t3code.png"
for f in t3code.desktop t3code-url-handler.desktop; do
  sed -e "s|__T3_APPIMAGE__|$app|g" -e "s|__T3_ICON__|$icon|g" \
    "$HOME/.dotfiles/t3code/$f" > "$HOME/.local/share/applications/$f"
done
update-desktop-database "$HOME/.local/share/applications"
```

## desktop config

T3 Code keeps desktop and server config under `~/.t3/userdata/`. The canonical
copies live in `t3code/userdata/`:

| file | purpose |
|---|---|
| `settings.json` | default model, providers, provider instances |
| `client-settings.json` | desktop preferences: fonts, diffs, slash-menu skills |
| `keybindings.json` | custom keybindings |

T3 Code rewrites these files atomically (temp file + rename), so a symlink would
be replaced on the first in-app change. Apply them by copying:

```bash
cp ~/.dotfiles/t3code/userdata/*.json ~/.t3/userdata/
```

To capture in-app changes back into the repo, copy the same files the other way.

## goal mode in t3 code

T3 Code runs the OpenCode config at `~/.config/opencode/opencode.json`. Configs
merge, so the global `plugin` list is preserved even though T3 Code starts the
server with `OPENCODE_CONFIG_CONTENT={}`: the goal, memory, background-agent,
token-tracker, autotitle, snip, mystatus, and i-have-adhd plugins are all active
in T3 Code sessions.

T3 Code v0.0.42 lists only `/compact` as an OpenCode provider command, so plugin
commands like `/goal` do not appear in its slash menu yet (command-catalog support
is on T3 Code `main`, unreleased). Until a release ships it, the `goal` skill in
`../opencode/skills/goal/` exposes goal mode from T3 Code's slash menu: type
`/goal` and pick the goal skill, or use `$goal`. After adding or changing skills,
run **Settings > Providers > Refresh provider status**.

## files

- `userdata/` -> canonical T3 Code desktop config
- `t3code.desktop` -> main launcher template
- `t3code-url-handler.desktop` -> `t3code://` scheme handler template
