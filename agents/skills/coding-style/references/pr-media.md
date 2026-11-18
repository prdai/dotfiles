# PR media

Required for UI changes. Capture before and after, plus a short recording, and attach them without asking.

## Capture

- Start the app and open the changed screen.
- Screenshot: T3 `preview_snapshot` with `save=true` returns `screenshotPath`. Capture one on the base branch and one on the change.
- Recording: T3 `preview_recording_start`, perform the interaction, `preview_recording_stop`. It returns a local path. Keep it under 30 seconds and 50 MiB.
- No preview tools: use Playwright MCP or the repo's own screenshot command. Do not describe the change instead of capturing it.

## Publish

GitHub has no API to upload media to a PR body or comment ([cli/cli#14302](https://github.com/cli/cli/issues/14302)). Use an orphan assets branch in the head fork:

```bash
tmp=$(mktemp -d)
git worktree add --detach "$tmp" HEAD
cd "$tmp"
git switch --orphan "assets/pr-<number>"
git rm -rf . >/dev/null 2>&1 || true
mkdir -p "pr-<number>"
cp <screenshots> <recording> "pr-<number>/"
git add "pr-<number>"
git commit -m "docs: add media for #<number>"
git push origin "HEAD:assets/pr-<number>"
cd -
git worktree remove "$tmp"
```

Do not merge or cherry-pick the assets branch into the code PR.

## Link

Use raw URLs so the images render:

- Image: `![after](https://raw.githubusercontent.com/<owner>/<repo>/assets/pr-<number>/pr-<number>/after.png)`
- Video: `[recording](https://raw.githubusercontent.com/<owner>/<repo>/assets/pr-<number>/pr-<number>/recording.webm)` because GitHub does not inline video from markdown.

Add a `## screenshots` section with before/after and the recording link.
