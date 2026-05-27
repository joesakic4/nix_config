# ── Host builder ─────────────────────────────────────────────────
# Assembles one nixosSystem from the shared modules + the host's own
# files. `specialArgs` is what threads `inputs` / `userName` / `hostName`
# into EVERY imported module (modules/*, hosts/*, hardware-configuration)
# for free — set once here, available everywhere.
#
# Add a new machine with a single line in flake.nix:
#   newbox = mkHost { hostName = "newbox"; };
# and a hosts/newbox/ dir (hardware-configuration.nix, disk-config.nix,
# default.nix).
#
{ inputs, nixpkgs, home-manager, disko, system, userName }:

{ hostName }:

nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = { inherit inputs userName hostName; };

  modules = [
    # Third-party NixOS modules
    disko.nixosModules.disko

    # Shared system config (one import pulls in all of modules/)
    ../modules

    # Per-host pieces
    ../hosts/${hostName}/disk-config.nix
    ../hosts/${hostName}/default.nix

    # Home Manager as a NixOS module: one `nixos-rebuild switch`
    # activates system + user config together.
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs   = true;
        useUserPackages = true;
        # How home/default.nix receives inputs / userName / hostName:
        extraSpecialArgs = { inherit inputs userName hostName; };
        users.${userName} = import ../home;
      };
    }
  ];
}
