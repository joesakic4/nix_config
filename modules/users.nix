# ── Primary user ─────────────────────────────────────────────────
# Base account shared by every host. Hosts may append extra groups,
# e.g. `users.users.${userName}.extraGroups = [ "kvm" ];` — NixOS
# merges list-valued options, so that appends rather than overrides.
{ pkgs, userName, ... }:
{
  users.users.${userName} = {
    isNormalUser = true;
    description  = "Primary account";
    extraGroups  = [
      "wheel"
      "networkmanager"
      "video"
      "render"          # Intel/NVIDIA GPU VA-API access
      "audio"
      "libvirtd"
      "input"
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
}
