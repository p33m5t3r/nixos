#!/usr/bin/env bash
# Handles clicks on the custom status bar. Arg is #{mouse_status_range}, set from
# the #[range=user|...] tags emitted by claude-status.sh:
#   h:<session>          -> clicked a session header  -> switch to it
#   w:<session>:<index>  -> clicked a window cell      -> switch there
r="$1"
case "$r" in
  h:*) tmux switch-client -t "${r#h:}" ;;
  w:*) rest="${r#w:}"; sess="${rest%:*}"; idx="${rest##*:}"
       tmux switch-client -t "$sess"; tmux select-window -t "$sess:$idx" ;;
esac   # empty / stats area: no match, do nothing
