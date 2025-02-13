{ config, lib, pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "kitty";
      menu = "wofi -s ~/.config/wofi/styles.css --show drun";
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      # Startup commands
      startup = [
        { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"; }
        { command = "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"; }
      ];

      # Global output configuration
      output = {
        "*" = {
          adaptive_sync = "on";
          render_bit_depth = "10";
        };
      };

      # Input configuration
      input = {
        "*" = {
          natural_scroll = "enabled";
        };
      };

      # Keybindings
      keybindings = let
        mod = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        # Basic bindings
        "${mod}+Return" = "exec ${terminal}";
        "${mod}+Shift+q" = "kill";
        "${mod}+space" = "exec ${menu}";
        "${mod}+Shift+r" = "reload";
        "${mod}+Shift+e" = "exec swaynag -t warning -m 'do u rly wna kill wayland?' -B 'yes, exit sway' 'swaymsg exit'";

        # Audio controls
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";

        # Focus movement
        "${mod}+${left}" = "focus left";
        "${mod}+${down}" = "focus down";
        "${mod}+${up}" = "focus up";
        "${mod}+${right}" = "focus right";

        # Window movement
        "${mod}+Shift+${left}" = "move left";
        "${mod}+Shift+${down}" = "move down";
        "${mod}+Shift+${up}" = "move up";
        "${mod}+Shift+${right}" = "move right";

        # Workspaces
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        # Move container to workspace
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        # Layout controls
        "${mod}+semicolon" = "splith";
        "${mod}+Shift+semicolon" = "splitv";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";
        "${mod}+f" = "fullscreen";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+t" = "focus mode_toggle";
        "${mod}+a" = "focus parent";
        "${mod}+r" = "mode resize";
      };

      # Modes
      modes = {
        resize = {
          ${left} = "resize shrink width 10px";
          ${down} = "resize grow height 10px";
          ${up} = "resize shrink height 10px";
          ${right} = "resize grow width 10px";
          "Return" = "mode default";
          "Escape" = "mode default";
          "${modifier}+r" = "mode default";
        };
      };

      # Colors
      colors = {
        focused = {
          background = "#1d2021";
          border = "#FFB6C1";
          childBorder = "#FFB6C1";
          indicator = "#FFB6C1";
          text = "#FFB6C1";
        };
        focusedInactive = {
          background = "#161819";
          border = "#7c6f64";
          childBorder = "#7c6f64";
          indicator = "#7c6f64";
          text = "#d4be98";
        };
        unfocused = {
          background = "#161819";
          border = "#7c6f64";
          childBorder = "#7c6f64";
          indicator = "#7c6f64";
          text = "#d4be98";
        };
        urgent = {
          background = "#e78a4e";
          border = "#e78a4e";
          childBorder = "#e78a4e";
          indicator = "#e78a4e";
          text = "#000000";
        };
      };

      # Bars
      bars = [{
        command = "waybar";
      }];

      # Window decoration
      window = {
        border = 1;
        titlebar = false;
      };

      # Gaps
      gaps = {
        inner = 4;
        outer = 4;
      };

      # Floating modifier
      floating = {
        modifier = "${modifier}";
      };
    };

    # Extra sway config that doesn't fit into the config attribute
    extraConfig = ''
      # for nvda gpu
      output * adaptive_sync on
      output * render_bit_depth 10
    '';
  };
}
