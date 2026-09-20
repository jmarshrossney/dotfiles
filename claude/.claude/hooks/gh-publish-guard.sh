#!/usr/bin/env bash
# PreToolUse/Bash guard: force a permission prompt for gh commands that publish
# content (comments, reviews, PR/issue bodies, merges, releases).
#
# Drafting is fine; uploading is the maintainer's call. Emits permissionDecision
# "ask" rather than "deny" so an approved command still runs after review.
set -uo pipefail

input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' 2>/dev/null <<<"$input") || exit 0
[ -n "$cmd" ] || exit 0

ask() {
  jq -nc --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Comments, reviews, and anything that changes a PR or issue's public state.
if grep -Eq '(^|[^[:alnum:]_-])gh[[:space:]]+(pr|issue)[[:space:]]+(comment|create|edit|close|reopen|merge|review|ready|lock|unlock|pin|unpin|transfer|delete)([[:space:]]|$)' <<<"$cmd"; then
  ask "Publishes to a PR or issue in your name. Read the draft before approving."
fi

# Releases, repo settings, gists.
if grep -Eq '(^|[^[:alnum:]_-])gh[[:space:]]+(release|repo|gist)[[:space:]]+(create|edit|delete|upload|archive|rename|fork)([[:space:]]|$)' <<<"$cmd"; then
  ask "Publishes or changes a repository, release, or gist. Review before approving."
fi

# gh api with a writing method or field arguments (fields imply POST).
if grep -Eq '(^|[^[:alnum:]_-])gh[[:space:]]+api([[:space:]]|$)' <<<"$cmd" \
   && grep -Eq '(-X|--method)[[:space:]]+(POST|PATCH|PUT|DELETE)|(^|[[:space:]])(-f|-F|--field|--raw-field|--input)([[:space:]]|=)' <<<"$cmd"; then
  ask "gh api write request. Review the payload before approving."
fi

# git push to anything other than origin: a contributor's fork, an explicit URL,
# or a branch whose upstream is not origin. Pushes to origin are ordinary work
# and pass through untouched.
if grep -Eq '(^|[^[:alnum:]_-])git([[:space:]]+(-C[[:space:]]+[^[:space:]]+|-{1,2}[^[:space:]]+))*[[:space:]]+push([[:space:]]|$)' <<<"$cmd"; then
  # Text after the push subcommand, cut at the next shell separator.
  rest=$(sed -E 's/.*[[:space:]]push([[:space:]]|$)/\1/' <<<"$cmd" | sed -E 's/[;&|].*//')
  remote=""
  skip_value=0
  for word in $rest; do
    if [ "$skip_value" = 1 ]; then skip_value=0; continue; fi
    case "$word" in
      -o|--push-option|--receive-pack|--exec|--repo) skip_value=1; continue ;;
      -*) continue ;;
      *) remote="$word"; break ;;
    esac
  done

  if [ -z "$remote" ]; then
    # No remote named: resolve the current branch's upstream instead.
    cwd=$(jq -r '.cwd // empty' 2>/dev/null <<<"$input")
    upstream=$(git -C "${cwd:-$PWD}" rev-parse --abbrev-ref '@{u}' 2>/dev/null)
    remote="${upstream%%/*}"
    [ -n "$remote" ] || exit 0
  fi

  case "$remote" in
    origin) ;;
    https://*|http://*|git@*|ssh://*|git://*|/*|./*|../*)
      ask "Pushes to an explicit remote URL, not origin. Confirm the target before approving." ;;
    *)
      ask "Pushes to remote '$remote' rather than origin, which may be a contributor fork. Confirm before approving." ;;
  esac
fi

exit 0
