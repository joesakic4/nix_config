# ── Desktop: Hyprland (Wayland) ──────────────────────────────────
{ pkgs, inputs, ... }:
{
  programs.hyprland = {
    enable  = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  xdg.portal = {
    enable       = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  programs.dconf.enable = true;

  # Polkit authentication agent — Hyprland ships no built-in one, so
  # GUI privilege prompts (e.g. from virt-manager) need this.
  systemd.user.services.polkit-gnome-agent = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy    = [ "graphical-session.target" ];
    wants       = [ "graphical-session.target" ];
    after       = [ "graphical-session.target" ];
    serviceConfig = {
      Type           = "simple";
      ExecStart      = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart        = "on-failure";
      RestartSec     = 1;
      TimeoutStopSec = 10;
    };
  };
}
