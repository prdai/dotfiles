# opencode

config for the [opencode](https://opencode.ai) agentic CLI/TUI, symlinked into `~/.config/opencode`.

## what's here

| file | purpose |
|---|---|
| `opencode.json` | server/runtime config: default models, permissions, compaction, tool output, global plugins |
| `tui.json` | terminal UI: theme, cursor, scroll, attention notifications |
| `AGENTS.md` | global agentic engineering rules (applied to all opencode sessions) |
| `themes/codex.json` | custom dark theme matching the Codex desktop app (`#181818` surfaces, light-blue accent, one-dark syntax) |
| `vendor/i-have-adhd/` | local plugin checkout, gitignored (cloned by the setup step below) |

## setup

```bash
ln -sf ~/.dotfiles/opencode ~/.config/opencode

# local plugin: i-have-adhd (gitignored; the global config points at this path)
git clone --depth 1 https://github.com/ayghri/i-have-adhd ~/.config/opencode/vendor/i-have-adhd
```

then restart opencode. config is loaded once at startup — no hot reload.

## plugins

global plugins live in the `plugin` array in `opencode.json`. both the terminal
CLI/TUI and the desktop app read this file (the desktop runs the same server), so
every plugin below applies to both. npm and git plugins install automatically at
startup into `~/.cache/opencode/`.

| plugin | purpose |
|---|---|
| `@prevalentware/opencode-goal-plugin` | Codex-style `/goal` long-running goal mode: persistence, auto-continue, TUI status |
| `superpowers@git+https://github.com/obra/superpowers.git` | skill/workflow suite (brainstorming, TDD, code review, worktrees) shared with pi + claude code |
| `opencode-agent-memory` | persistent, self-editable memory blocks (Letta-style) |
| `opencode-background-agents` | async background subagent delegation with context persistence |
| `opencode-token-tracker` | real-time token/cost tracking, toasts, and the `opencode-tokens` CLI |
| `opencode-autotitle` | AI session titles on the cheapest available model |
| `opencode-snip` | prefixes shell calls with `snip` to cut tool-output tokens 60-90% |
| `opencode-mystatus` | check AI subscription quotas (OpenAI, Z.ai, Antigravity, ...) |
| `./vendor/i-have-adhd/.opencode/plugins/i-have-adhd.mjs` | ADHD/focus output mode: `/i-have-adhd` command + optional always-on |

install / reinstall:

```bash
# npm plugins install at startup; to (re)install or update them explicitly:
opencode plugin -g @prevalentware/opencode-goal-plugin
opencode plugin -g opencode-agent-memory
opencode plugin -g opencode-background-agents
opencode plugin -g opencode-token-tracker
opencode plugin -g opencode-autotitle
opencode plugin -g opencode-snip
opencode plugin -g opencode-mystatus

# superpowers (git) and i-have-adhd (local) are declared directly in opencode.json;
# clone the local one as shown in setup above.

# optional: activate opencode-snip (the plugin no-ops without it)
curl -fsSL https://raw.githubusercontent.com/edouard-claude/snip/master/install.sh | sh
```

plugin notes:

- `opencode-snip` disables itself until the `snip` binary is on `PATH`.
- `opencode-agent-memory` pulls `@huggingface/transformers`; the first run downloads models.
- `opencode-token-tracker` also installs an `opencode-tokens` CLI.
- i-have-adhd always-on: `touch ~/.config/opencode/.i-have-adhd-always` (gitignored).
- TUI-only plugins (sidebars/statuslines) do not render in the desktop app and are intentionally excluded.

## notes

- theme values: `system`, `tokyonight`, `everforest`, `ayu`, `catppuccin(-macchiato)`,
  `gruvbox`, `kanagawa`, `nord`, `matrix`, `one-dark`, plus the custom `codex` theme above.
- `opencode.json`/`tui.json` are validated strictly — changes are best confirmed via
  the `^`+`^` config check or a `~/.config/opencode` restart before committing.
