#!/bin/sh
input=$(cat)

branch=$(echo "$input" | jq -r '.worktree.branch // empty')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
model_id=$(echo "$input" | jq -r '.model.id // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

parts=""

[ -n "$branch" ] && {
  [ -n "$parts" ] && parts="$parts :: $branch" || parts="$branch"
}

[ -n "$current_dir" ] && {
  [ -n "$parts" ] && parts="$parts :: $current_dir" || parts="$current_dir"
}

[ -n "$model_id" ] && {
  [ -n "$parts" ] && parts="$parts :: $model_id" || parts="$model_id"
}

[ -n "$used_pct" ] && {
  [ -n "$parts" ] && parts="$parts :: ${used_pct}% used" || parts="${used_pct}% used"
}

echo "$parts"
