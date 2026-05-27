# ── Hyprland WM configuration (managed by Home Manager) ─────────
{ config, pkgs, lib, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {

      # ── Monitor layout ────────────────────────────────────────
      # Format: name, resolution@hz, position, scale
      # Run `hyprctl monitors` to see your outputs, then adjust.
      monitor = [
        ",preferred,auto,1"        # catch-all: use native res
        # "DP-1, 2560x1440@165, 0x0, 1"
        # "HDMI-A-1, 1920x1080@60, 2560x0, 1"
      ];

      # ── Environment variables ─────────────────────────────────
      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
        "QT_QPA_PLATFORMTHEME,qt5ct"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
      ];

      # ── Startup daemons ───────────────────────────────────────
      exec-once = [
        "waybar"
        "dunst"
        "swww-daemon"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        # "swww img ~/Pictures/wallpaper.png"   # set a wallpaper
      ];

      # ── Input ─────────────────────────────────────────────────
      input = {
        kb_layout  = "us";
        # kb_variant = "";
        # kb_options = "caps:escape";  # remap caps → esc like a civilised person
        follow_mouse    = 1;
        sensitivity     = 0;
        touchpad = {
          natural_scroll = true;
          tap-to-click   = true;
        };
      };

      # ── Look & feel ───────────────────────────────────────────
      general = {
        gaps_in     = 4;
        gaps_out    = 8;
        border_size = 2;
        "col.active_border"   = "rgba(89b4faee) rgba(cba6f7ee) 45deg";
        "col.inactive_border" = "rgba(585b70aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled   = true;
          size      = 6;
          passes    = 3;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range   = 8;
          render_power = 2;
          color = "rgba(1a1a2eee)";
        };
      };

      animations = {
        enabled = true;
        bezier  = [ "ease, 0.25, 0.1, 0.25, 1" ];
        animation = [
          "windows,     1, 4, ease"
          "windowsOut,  1, 4, ease, popin 80%"
          "fade,        1, 4, ease"
          "workspaces,  1, 4, ease, slide"
        ];
      };

      dwindle = {
        pseudotile      = true;
        preserve_split   = true;
        force_split      = 2;   # always split to the right / bottom
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo   = true;
      };

      # ── Key bindings ──────────────────────────────────────────
      "$mod" = "SUPER";

      bind = [
        # ── Core ──────────────────────────
        "$mod, Return,  exec, kitty"
        "$mod, Q,       killactive,"
        "$mod, M,       exit,"
        "$mod, E,       exec, thunar"
        "$mod, F,       togglefloating,"
        "$mod, Space,   exec, wofi --show drun -I"
        "$mod, P,       pseudo,"
        "$mod, J,       togglesplit,"
        "$mod SHIFT, F, fullscreen, 0"

        # ── Screenshots ───────────────────
        ", Print,       exec, grim -g \"$(slurp)\" - | wl-copy"
        "SHIFT, Print,  exec, grim - | wl-copy"

        # ── Clipboard history ─────────────
        "$mod, V,       exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

        # ── Lock ──────────────────────────
        "$mod, L,       exec, swaylock -f --clock --indicator"

        # ── Focus ─────────────────────────
        "$mod, left,    movefocus, l"
        "$mod, right,   movefocus, r"
        "$mod, up,      movefocus, u"
        "$mod, down,    movefocus, d"

        # ── Move windows ──────────────────
        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"

        # ── Workspaces 1-9 ────────────────
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # ── Move window to workspace ──────
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # ── Scroll through workspaces ─────
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up,   workspace, e-1"
      ];

      # ── Mouse binds ────────────────────────────────────────────
      bindm = [
        "$mod, mouse:272, movewindow"     # super + left-click drag
        "$mod, mouse:273, resizewindow"   # super + right-click drag
      ];

      # ── Media / brightness keys ────────────────────────────────
      bindel = [
        ", XF86AudioRaiseVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute,         exec, wpctl set-mute   @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp,   exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      # ── Window rules ───────────────────────────────────────────
      windowrulev2 = [
        "float,       class:^(pavucontrol)$"
        "float,       class:^(virt-manager)$"
        "size 80% 80%, class:^(virt-manager)$"
        "float,       class:^(thunar)$"
        "float,       title:^(Open File)$"
        "float,       title:^(Save As)$"
      ];
    };
  };
}
