{
  description = "Multi-host NixOS + Home Manager (Hyprland) config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, disko, ... }@inputs:
    let
      system   = "x86_64-linux";
      userName = "joesakic4";

      mkHost = import ./lib/mkHost.nix {
        inherit inputs nixpkgs home-manager disko system userName;
      };
    in
    {
      nixosConfigurations = {
        # ── Real machines (one line each — add new hosts here) ──────
        default   = mkHost { hostName = "default"; };
        precision = mkHost { hostName = "precision"; };

        # ── Live installer ISO ──────────────────────────────────────
        # Just another nixosConfiguration that imports the upstream
        # installer module. Built via `nix build .#iso` (see below).
        iso = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs userName; hostName = "nixos-installer"; };
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./iso/default.nix
          ];
        };
      };

      # Convenience: `nix build .#iso` -> result/iso/*.iso
      packages.${system}.iso =
        self.nixosConfigurations.iso.config.system.build.isoImage;
    };
}
