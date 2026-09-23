# opencode

config for the [opencode](https://opencode.ai) agentic CLI/TUI, symlinked into `~/.config/opencode`.

## what's here

| file | purpose |
|---|---|
| `opencode.json` | server/runtime config: default models, permissions, compaction, tool output, global plugins |
| `tui.json` | terminal UI: theme, cursor, scroll, attention notifications |
| `AGENTS.md` | global agentic engineering rules (applied to all opencode sessions) |
| `themes/codex.json` | custom dark theme matching the Codex desktop app (`#181818` surfaces, light-blue accent, one-dark syntax) |
| `skills/` | relative symlinks to the vendored skills in `../agents/skills/`, loaded globally by opencode |
| `plugins/rtk.ts` | rtk command rewriting for bash/shell tool calls (needs `rtk` on PATH) |
| `vendor/i-have-adhd/` | local plugin checkout, gitignored (cloned by the setup step below) |

## setup

```bash
ln -sf ~/.dotfiles/opencode ~/.config/opencode

# local plugin: i-have-adhd (gitignored; the global config points at this path)
git clone --depth 1 https://github.com/ayghri/i-have-adhd ~/.config/opencode/vendor/i-have-adhd
```

then restart opencode. config is loaded once at startup — no hot reload.

## rtk (opencode command rewrite)

[rtk](https://github.com/rtk-ai/rtk) adds command-output compaction and supports opencode via `rtk init -g --opencode`.

install (linux/macos):

```bash
# homebrew (recommended)
brew install rtk

# quick install (linux/macos)
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

for windows and other install methods, see the upstream installation docs:
https://github.com/rtk-ai/rtk?tab=readme-ov-file#installation

quick install path note (linux/macos):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc
```

initialize opencode integration:

```bash
rtk init -g --opencode
```

this writes `plugins/rtk.ts` (committed here); the plugin is a thin delegating wrapper around
`rtk rewrite` and disables itself when `rtk` is not on PATH.

## skills

agent skills follow the [opencode skills spec](https://opencode.ai/docs/skills/): one folder
per skill with a `SKILL.md` carrying `name` + `description` frontmatter. skill sources are
vendored in this repo at `../agents/skills/<name>/` (shared with pi and T3 Code) and exposed
to opencode through two paths:

- `~/.agents/skills/<name>` → `~/.dotfiles/agents/skills/<name>` (created by the root README setup loop)
- `opencode/skills/<name>` → `../../agents/skills/<name>` (committed relative symlink; resolves through the `~/.config/opencode` symlink)

opencode discovers global skills under `~/.config/opencode/skills/`, `~/.agents/skills/`,
and `~/.claude/skills/`, so either path loads them for every session.

| skill | source (license) | purpose |
|---|---|---|
| `coding-style` | this repo | prdai's personal code style, required for all code / commit / PR work |
| `goal` | this repo | goal-mode entry point for frontends that list skills but not plugin slash commands (T3 Code v0.0.42 lists only `/compact`) |
| `better-ui` | jakubkrehel/skills (MIT) | values-first UI polish: concentric radii, optical alignment, surfaces, icons, hit areas |
| `emil-design-eng` | emilkowalski/skills (MIT) | Emil Kowalski's design-engineering philosophy and taste |
| `apple-design` | emilkowalski/skills (MIT) | Apple's fluid-interface motion and interaction principles for the web |
| `workers-best-practices` | cloudflare/skills (Apache-2.0) | production Cloudflare Workers patterns and platform limits |
| `wrangler` | cloudflare/skills (Apache-2.0) | wrangler CLI and Worker project configuration |
| `webapp-testing` | anthropics/skills (Apache-2.0) | Playwright-driven local web app testing |
| `codebase-design` | mattpocock/skills (MIT) | deep-module design vocabulary: interfaces, seams, testability |
| `code-review` | mattpocock/skills (MIT) | two-axis standards + spec review; the spec axis needs `setup-matt-pocock-skills` run per repo |
| `resolving-merge-conflicts` | mattpocock/skills (MIT) | resolve merge/rebase conflicts by intent, never `--abort` |
| `omarchy` | basecamp/omarchy (MIT) | Linux desktop / Hyprland / Waybar / Omarchy system config |
| `figma` | openai/skills curated (Figma Developer Terms) | Figma MCP design-to-code workflow; terms in the bundled `LICENSE.txt` |

the remaining skills in `../agents/skills/` (`agents-md` through `web-design-guidelines`) are
pi's skills, vendored here so opencode, pi, and T3 Code all read one copy.

to add another: vendor the skill folder into `agents/skills/<name>/`, run the symlink loop
from the root README, and commit a matching `opencode/skills/<name>` relative symlink.

## plugins

global plugins live in the `plugin` array in `opencode.json`. both the terminal
CLI/TUI and the desktop app read this file (the desktop runs the same server), so
every plugin below applies to both. npm and git plugins install automatically at
startup into `~/.cache/opencode/`.

| plugin | purpose |
|---|---|
| `@prevalentware/opencode-goal-plugin` | Codex-style `/goal` long-running goal mode: persistence, auto-continue, TUI status |
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

# i-have-adhd (local) is declared directly in opencode.json;
# clone it as shown in setup above.

# optional: activate opencode-snip (the plugin no-ops without it)
curl -fsSL https://raw.githubusercontent.com/edouard-claude/snip/master/install.sh | sh
```

plugin notes:

- `opencode-snip` disables itself until the `snip` binary is on `PATH`.
- `opencode-agent-memory` pulls `@huggingface/transformers`; the first run downloads models.
- `opencode-token-tracker` also installs an `opencode-tokens` CLI.
- i-have-adhd always-on: `touch ~/.config/opencode/.i-have-adhd-always` (gitignored).
- TUI-only plugins (sidebars/statuslines) do not render in the desktop app and are intentionally excluded.
- skills live in `../agents/skills/` and are shared by opencode, pi, and T3 Code; see the skills section above.

## notes

- theme values: `system`, `tokyonight`, `everforest`, `ayu`, `catppuccin(-macchiato)`,
  `gruvbox`, `kanagawa`, `nord`, `matrix`, `one-dark`, plus the custom `codex` theme above.
- `opencode.json`/`tui.json` are validated strictly — changes are best confirmed via
  the `^`+`^` config check or a `~/.config/opencode` restart before committing.
