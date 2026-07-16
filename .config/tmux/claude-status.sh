#!/usr/bin/env bash
# Single status row of every session + its windows, in choose-tree order
# (by session_id, i.e. creation order) so the "(N)" shown matches the number
# you press in `prefix + s`.
#   Background = location:  active session -> grey, active window -> pink, else bar black.
#   Foreground = Claude state (from @claude window option, set by Claude Code hooks):
#                busy -> pastel yellow, done -> pastel green, idle -> white.
# ponytail: names assumed newline-free (they are); overflow truncates at the right edge.

BAR='#1c1c1c'   # bar background (near-black)
SESS='#4d4d4d'  # active-session region (grey)
PINK='#f7b6c2'  # active window
FG='#d0d0d0'    # default text (whitish)
BUSY='#f2d98d'  # pastel yellow
DONE='#a8e0a0'  # pastel green
ATTN='#f0a0a0'  # pastel red
INK='#1c1c1c'   # text on the pink active window
SEP='#666666'   # session separator

esc() { printf '%s' "${1//#/##}"; }   # a literal # in a name reads as a tmux format

me="$1"   # session the *viewing* client is on (from #{client_session}); highlight only this one

i=0
first=1
tmux list-sessions -F '#{session_id} #{session_attached} #{session_name}' | sort -t'$' -k2 -n |
while read -r sid att sess; do
  [ "$sess" = "$me" ] && att=1 || att=0   # "current" = this client's session, not just any attached one
  [ "$att" = 1 ] && sbg="$SESS" || sbg="$BAR"
  [ "$first" = 1 ] || printf '#[bg=%s,fg=%s] :: ' "$BAR" "$SEP"
  first=0
  # range=user tags make cells clickable (handled by claude-click.sh via MouseDown1Status)
  printf '#[range=user|h:%s]#[bg=%s,fg=%s,bold] (%s) %s #[norange]#[default]' \
    "$(esc "$sess")" "$sbg" "$FG" "$i" "$(esc "$sess")"

  tmux list-windows -t "$sess" -F '#{window_active} #{?@claude,#{@claude},idle} #{window_index} #{window_name}' |
  while read -r active state idx name; do
    case "$state" in busy) fg="$BUSY";; done) fg="$DONE";; *) fg="$FG";; esac
    if [ "$att" = 1 ] && [ "$active" = 1 ]; then
      printf '#[range=user|w:%s:%s]#[bg=%s,fg=%s,bold] %s:%s #[norange]#[default]' \
        "$(esc "$sess")" "$idx" "$PINK" "$INK" "$idx" "$(esc "$name")"
    else
      printf '#[range=user|w:%s:%s]#[bg=%s,fg=%s] %s:%s #[norange]#[default]' \
        "$(esc "$sess")" "$idx" "$sbg" "$fg" "$idx" "$(esc "$name")"
    fi
  done
  i=$((i + 1))
done

# ---- right side: memory used/total, CPU load%, clock ----
# used = total - (free + speculative): tracks toward full under pressure (matches `top`).
# CPU% = 1-min load average / cores * 100 (cheap, no sampling delay, good runaway signal).
total=$(sysctl -n hw.memsize)
read used totalg < <(vm_stat | awk -v total="$total" '
  /page size of/ {ps=$8}
  $1=="Pages" && $2=="free:" {f=$3}
  $2=="speculative:" {sp=$3}
  END {gsub(/\./,"",f); gsub(/\./,"",sp);
       printf "%.1f %.0f", (total-(f+sp)*ps)/1073741824, total/1073741824}')
load=$(sysctl -n vm.loadavg | awk '{print $2}')
cpupct=$(awk -v l="$load" -v n="$(sysctl -n hw.ncpu)" 'BEGIN{printf "%.1f", l/n*100}')
clock=$(date +%H:%M)

memcol="$FG"; awk "BEGIN{exit !($used/$totalg>0.85)}" && memcol="$ATTN"
cpucol="$FG"; awk "BEGIN{exit !($cpupct>90)}"         && cpucol="$ATTN"

printf '#[align=right]#[bg=%s,fg=%s][#[fg=%s]%s/%sG#[fg=%s]][#[fg=%s]%s%%#[fg=%s]][%s] ' \
  "$BAR" "$FG" "$memcol" "$used" "$totalg" "$FG" "$cpucol" "$cpupct" "$FG" "$clock"
