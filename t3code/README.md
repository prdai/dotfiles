# t3code

launcher + installer for [T3 Code](https://github.com/pingdotgg/t3code), a GUI for AI coding agents.

## why the launcher exists

T3 Code ships as an AppImage, which needs `libfuse.so.2`. Ubuntu 24.04 ships
fuse3 only, so launching the AppImage directly fails with
`dlopen(): error loading libfuse.so.2`. The desktop entries here run it with
`APPIMAGE_EXTRACT_AND_RUN=1`, which extracts to a temp dir and runs without FUSE.

## setup

```bash
~/.dotfiles/t3code/install.sh
```

The installer fetches the latest release, verifies the published sha512,
installs it to `~/Applications/T3-Code-<version>-x86_64.AppImage`, points
`~/Applications/t3code.AppImage` at it, and writes the desktop entries to
`~/.local/share/applications/`.

## upgrade

Re-run `install.sh`. It fetches the latest release, verifies it, and repoints the symlink.

## files

- `install.sh` -> download, verify, install, upgrade
- `t3code.desktop` -> main launcher
- `t3code-url-handler.desktop` -> `t3code://` scheme handler
