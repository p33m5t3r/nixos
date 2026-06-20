# claude statusline

Reproduces the Claude Code statusline: `branch :: dir :: model :: %used`.

## Setup on a new machine

1. **Symlink the dir** (so `~/.config/claude` points at this repo):

   ```sh
   ln -sf "$PWD/.config/claude" ~/.config/claude
   ```

2. **Enable it** in `~/.claude/settings.json` — add this top-level block
   (that file is account-specific and lives outside this repo, so paste rather
   than symlink):

   ```json
   "statusLine": {
     "type": "command",
     "command": "sh ~/.config/claude/statusline-command.sh"
   }
   ```

3. **Dependency:** the script needs `jq`. On NixOS add `pkgs.jq` to your
   `environment.systemPackages` (in `shared.nix`) and rebuild.
