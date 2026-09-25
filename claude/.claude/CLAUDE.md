## Short-hand

- "Joe" means the user

## Prose

Applies to prose you write anywhere: markdown files, LaTeX and typst documents, GitHub PR and issue bodies, commit message bodies, and docstrings.
Not to code.

**One sentence per line, in prose that will be rendered.**
Break the line after each sentence rather than wrapping at a column.
A sentence runs as long as it runs.
This is for the diff: reflowing a paragraph to fit 80 columns rewrites every line in it, so a one-word edit reads as a five-line change and the reviewer has to find the actual difference by eye.
One sentence per line makes the edit self-evident.
Rendering is unaffected — markdown, LaTeX and typst all collapse a single newline into a space.
If a sentence is uncomfortably long on one line, that is usually a sentence worth splitting.
Exception: if a file already uses hard column wrapping, match it; reflowing someone else's document is a separate change from the one you were asked to make.

This covers `.md`, `.tex` and `.typ` files, PR and issue bodies, commit message bodies, and prose inside executable notebooks: marimo `mo.md()` cells, Jupyter markdown cells, and jupytext `# %% [markdown]` blocks.
A notebook living in a `.py` file does not make its markdown code.
Those cells get exported and rendered, and hard wrapping survives the export, where it is awkward to read and breaks inline math that lands across a line break.
`E501` is not in ruff's default rule set, so this usually costs nothing.
Where a repo does enable it, the fix is a per-file-ignore for the notebook paths rather than a `# noqa` you cannot place cleanly; changing my lint configuration is my call, so raise it rather than doing it.

**Prose that is only ever read as source is the exception: wrap to the file's line length.**
Docstrings, and comments explaining the code around them, are read in a narrow editor pane rather than rendered, and sit under a line-length lint (`line-length` in `[tool.ruff]`, else 88).
A 200-character docstring line is a lint failure and unreadable besides.
Hand-wrap those, since formatters will not rewrap string contents for you.

**State the result, not the journey.**
No preamble, no restating the question, no summarising what you just said.
Report what happened, including when it did not work.

**Prefer structure to paragraphs where it carries the same information.**
Tables for anything with repeated fields, numbered lists for genuine sequences, bullets otherwise.

**PR and issue bodies: what changed and why, then whatever a reviewer needs to check.**
No feature-announcement voice, no emoji headings, no restating the diff line by line.

## Memory

Never write to the file-based memory directory under `~/.claude/projects/<project>/memory/`.

When something is worth keeping, put it where it will be seen and can be reviewed in a diff, in this order:

1. Tooling that makes the good decision the only available one: a test, a lint rule, a CI check, a schema, a lockfile, a template. This is STRONGLY preferred over the remaining options.
2. `AGENTS.md` in the repository, for anything specific to that repository.
3. This file, for anything that applies across my projects.
4. A skill, last resort, and only when the thing is a procedure rather than a fact.

If a session turns up something worth keeping, say so and propose which of these it belongs in.
Do not act on it silently.

## Publishing on my behalf

Never post to a public issue or pull request unless the user explicitly requests it.
This covers comments, replies, inline review comments and review submissions, PR and issue titles and bodies, closing, reopening, merging, releases, and pushing to someone else's branch.
It applies to my repositories and to anyone else's.

Common requests include opening issues and pull requests in the user's own repositories under github.com/jmarshrossney.
It is highly unlikely the user will request such an action under anyone else's repository.

When asked to draft an issue, pull request or comment, write it to a markdown file in the working directory so the user can review, edit it appropriate, and post.

A `PreToolUse` hook (`~/.claude/hooks/gh-publish-guard.sh`) turns publishing `gh` commands into a permission prompt, so this is enforced rather than remembered.
Treat a prompt from it as a stop, not a speed bump: if I have not asked you to post, the answer is to show me the draft instead.
