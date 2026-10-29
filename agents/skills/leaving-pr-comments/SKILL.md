---
name: leaving-pr-comments
description: Format agent-authored GitHub comments. Use only when the user has authorized a comment to be posted.
---

# Leaving PR Comments

Posting is the user's call. Do not post, reply to reviewers, or resolve threads
unless the user explicitly authorized it for this task.

When a comment is authorized, prefix it with this GitHub note callout:

```md
> [!NOTE]
> **<model> responding on behalf of <user>**

Actual comment starts here.
```

Use the verified public name of the model that wrote the comment, and the user's
name or GitHub login.

If the harness does not expose a model name, use the harness name. Do not guess.

Before posting, check the entire comment, including quoted text and
attachments, for secrets and private details.

Keep the attribution inside the note and the actual reply outside it. The
context line must start with the model attribution and must not use emoji. Do
not add a horizontal rule, Setext underline, heading, signature footer, or a
second attribution.

Apply this format to top-level PR comments, inline review comments, replies to
bots or reviewers, and written explanations used before resolving or dismissing
feedback. Do not add it to PR descriptions, commit messages, or text the user
explicitly asked to post verbatim without attribution.

Write the comment itself in a direct style:

- Lead with the conclusion.
- Cite the relevant code, behavior, check, or reproduction.
- Keep it concise and avoid filler, canned thanks, or status narration.
- Distinguish verified facts from judgment.

Preview the final Markdown before posting so quoting and blank lines render as
shown. After posting, verify that GitHub returned the comment or review URL.
Resolve a review thread only after its response was posted successfully.

Origin: adapted from t3dotgg/tstack leaving-pr-comments, with emoji removed and
the posting-authorization rule made explicit.
