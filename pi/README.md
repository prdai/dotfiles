# pi config

Personal [pi](https://pi.dev) coding agent configuration — extensions, skills, settings, and themes. Synced across devices via git.

## Setup

```bash
git clone https://github.com/prdai-archive/pi-config.git ~/.pi
cd ~/.pi/agent/npm && npm install
ln -s npm/node_modules ~/.pi/agent/node_modules  # extensions resolve deps via this symlink
export ANTHROPIC_API_KEY=sk-ant-...  # or run /login inside pi
pi
```

## What's inside

### Extensions (`agent/extensions/`)

| Extension | What it does |
|---|---|
| **bash-guard** | Intercepts destructive bash calls — prompts in main session, hard-blocks in subagents |
| **subagents** | Register a `subagent` tool: scout (codebase recon), researcher (web), worker (code edits) |
| **web-search** | Google web search tool |
| **web-fetch** | Fetch and parse web pages |
| **youtube-search** | YouTube video search |
| **video-extract** | Extract video transcripts/content |
| **google-image-search** | Google image search |
| **memory** | Persistent memory across sessions |
| **filechanges** | Tracks file changes during sessions |
| **context** | Dynamic context injection |
| **md-link** | Markdown link handling |
| **ask-user-question** | Prompts user for input mid-task |
| **custom-header** | Custom request headers |
| **zz-read-only-mode** | Read-only file system mode (loaded last) |
| **clear-command** | `/clear` to start a fresh session |
| **omarchy-system-theme** | Auto-syncs pi theme with your Omarchy light/dark mode |

### Skills (`agent/skills/`)

| Skill | Description |
|---|---|
| **omarchy** | Linux desktop / Hyprland / Waybar / system config management |
| **orchestrator** | Multi-agent task orchestration |
| **stop-slop** | Anti-slop — cuts AI fluff and filler language |

### Theme

**ghostty-sync** — dark theme synced with your Ghostty terminal palette.

### Packages

```json
"npm:pi-opencode-bridge"
"npm:@ogulcancelik/pi-goal"
"npm:@ogulcancelik/pi-minimal-footer"
"npm:@ogulcancelik/pi-model-agents"
"npm:@ogulcancelik/pi-model-thinking"
"npm:@ogulcancelik/pi-spar"
"npm:@ogulcancelik/pi-web-browse"
"npm:@ogulcancelik/pi-ghostty-theme-sync"
```

### Defaults

- **Provider**: `opencode-go`
- **Model**: `deepseek-v4-flash`
- **Thinking**: `high`

## What stays local

Gitignored — never pushed:

| Path | Reason |
|---|---|
| `agent/auth.json` | API keys |
| `agent/sessions/` | Chat history |
| `agent/spar/` | Spar conversation history |
| `**/node_modules/` | Dependencies |

## Sync

```bash
# Pull latest
cd ~/.pi && git pull

# Push changes
cd ~/.pi && git add -A && git commit -m "update config" && git push
```
