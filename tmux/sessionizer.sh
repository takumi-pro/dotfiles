#!/usr/bin/env bash
set -eu

selected=$(ghq list | fzf --reverse --prompt 'session > ')
[ -z "${selected:-}" ] && exit 0

session_name=$(basename "$selected")
repo_path="$(ghq root)/$selected"

if ! tmux has-session -t "=$session_name" 2>/dev/null; then
  tmux new-session -ds "$session_name" -c "$repo_path"
fi

if [ -n "${TMUX:-}" ]; then
  tmux switch-client -t "$session_name"
else
  tmux attach-session -t "$session_name"
fi
