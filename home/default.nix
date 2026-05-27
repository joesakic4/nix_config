# ── Home Manager – per-user dotfiles & programs ─────────────────
{ config, pkgs, lib, inputs, userName, ... }:
{
  imports = [
    ./hyprland.nix
  ];

  home.username      = userName;
  home.homeDirectory = "/home/${userName}";
  home.stateVersion  = "25.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # ── Git ────────────────────────────────────────────────────────
  programs.git = {
    enable    = true;
    settings = {
      user.name  = "";
      user.email = "";
      init.defaultBranch = "main";
      pull.rebase        = true;
    };
  };

  # ── Shell (zsh) ────────────────────────────────────────────────
  programs.zsh = {
    enable               = true;
    enableCompletion     = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll   = "ls -la";
      # No host suffix: nixos-rebuild matches nixosConfigurations.<hostname>
      # to the live machine automatically, so these are correct everywhere.
      nrs  = "sudo nixos-rebuild switch --flake .";
      nrt  = "sudo nixos-rebuild test --flake .";
      nfu  = "nix flake update";
      vim  = "nvim";
    };
    oh-my-zsh = {
      enable  = true;
      theme   = "robbyrussell";
      plugins = [ "git" "z" "docker" "sudo" ];
    };
  };

  # ── Terminal (Kitty) ───────────────────────────────────────────
  programs.kitty = {
    enable   = true;
    settings = {
      font_family      = "JetBrainsMono Nerd Font";
      font_size        = 12;
      background_opacity = "0.92";
      confirm_os_window_close = 0;
      enable_audio_bell = "no";
      window_padding_width = 8;
    };
  };

  # ── Waybar ─────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer    = "top";
        position = "top";
        height   = 34;
        modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right  = [
          "pulseaudio" "network" "cpu" "memory" "battery" "tray"
        ];

        clock = {
          format         = "{:%H:%M  %a %d %b}";
          tooltip-format = "{:%Y-%m-%d | %H:%M:%S}";
        };
        cpu     = { format = "  {usage}%"; };
        memory  = { format = "  {percentage}%"; };
        battery = {
          format          = "{icon}  {capacity}%";
          format-icons    = [ "" "" "" "" "" ];
        };
        network = {
          format-wifi         = "  {signalStrength}%";
          format-disconnected = "⚠  offline";
        };
        pulseaudio = {
          format       = "{icon}  {volume}%";
          format-muted = "  muted";
          format-icons.default = [ "" "" "" ];
          on-click     = "pavucontrol";
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", sans-serif;
        font-size: 13px;
      }
      window#waybar {
        background: rgba(30, 30, 46, 0.85);
        color: #cdd6f4;
      }
      #workspaces button {
        padding: 0 8px;
        color: #cdd6f4;
      }
      #workspaces button.active {
        color: #89b4fa;
        border-bottom: 2px solid #89b4fa;
      }
      #clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray {
        padding: 0 10px;
      }
    '';
  };

  # ── Cursor / GTK theme (so apps don't look like 1995) ──────────
  home.pointerCursor = {
    name    = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size    = 24;
  };
  gtk = {
    enable = true;
    theme = {
      name    = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name    = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # ── Extra user packages ────────────────────────────────────────
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    fastfetch
    lazygit
    fzf
    bat
    eza
    trash-cli
  ];

  # ── XDG dirs ───────────────────────────────────────────────────
  xdg.userDirs = {
    enable     = true;
    createDirectories = true;
    desktop    = "${config.home.homeDirectory}/Desktop";
    documents  = "${config.home.homeDirectory}/Documents";
    download   = "${config.home.homeDirectory}/Downloads";
    music      = "${config.home.homeDirectory}/Music";
    pictures   = "${config.home.homeDirectory}/Pictures";
    videos     = "${config.home.homeDirectory}/Videos";
  };
}
