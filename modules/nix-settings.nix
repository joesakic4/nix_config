# ── Nix daemon settings ──────────────────────────────────────────
{ userName, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store   = true;
      trusted-users         = [ "root" userName ];
    };
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 14d";
    };
  };
  nixpkgs.config.allowUnfree = true;
}
