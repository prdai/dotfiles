# systemd

user-level systemd units used by this setup.

## setup

```bash
ln -sf ~/.dotfiles/systemd/user/obsidian-sync.service ~/.config/systemd/user/obsidian-sync.service
ln -sf ~/.dotfiles/systemd/user/opencode-serve.service ~/.config/systemd/user/opencode-serve.service
systemctl --user daemon-reload
systemctl --user enable --now obsidian-sync.service
systemctl --user enable --now opencode-serve.service
```

## files

- `user/obsidian-sync.service` → runs obsidian vault git sync script on session start/stop.
- `user/opencode-serve.service` → headless opencode HTTP server bound to the tailnet IP, auth via `~/.config/opencode-serve.env`.
