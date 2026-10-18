# Patches vs upstream 0.2.0

Upstream: [joshuadavidthomas/opencode-agent-memory](https://github.com/joshuadavidthomas/opencode-agent-memory) @ 0.2.0 (MIT).

1. **Drop per-turn wall-clock from system prompt** (`src/prompt.ts`)  
   `new Date().toISOString()` in `<memory_metadata>` changed every request and busted the prompt-cache prefix after ~22k tokens.

2. **Append memory after the stable system prefix** (`src/plugin.ts`)  
   Upstream spliced memory at system index 1. Appending keeps tools/core instructions cacheable; memory edits only invalidate the trailing chunk.
