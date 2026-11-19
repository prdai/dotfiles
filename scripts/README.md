# scripts

small utility scripts used by this dotfiles setup.

## files

- `obsidian-sync.sh` → auto-commit/pull/push for `~/Documents/obsidian-vault` on login/logout.
- `nvidia-chat.sh` → one-shot call to a hosted NVIDIA NIM model; prompt on stdin, needs `NVIDIA_API_KEY`.

## usage

```bash
~/.dotfiles/scripts/obsidian-sync.sh login
~/.dotfiles/scripts/obsidian-sync.sh logout
echo "review this diff" | ~/.dotfiles/scripts/nvidia-chat.sh nvidia/nemotron-3-ultra-550b-a55b
```
