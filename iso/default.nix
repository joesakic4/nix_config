# ── Custom install ISO ───────────────────────────────────────────
#
# Build:  nix build .#iso
# Flash:  sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress oflag=sync
#
# This gives you a live environment with your flake repo,
# networking, and the tools needed to partition + install.
#
{ config, pkgs, lib, inputs, userName, hostName, ... }:
{
  # The minimal installer module is already imported in flake.nix.

  # ── Extra packages baked into the ISO ─────────────────────────
  environment.systemPackages = with pkgs; [
    git
    neovim
    curl
    wget
    parted
    gptfdisk        # sgdisk
    dosfstools      # mkfs.vfat
    e2fsprogs       # mkfs.ext4
    nixos-install-tools
    htop
  ];

  # Networking in the live env
  networking = {
    hostName = "nixos-installer";
    networkmanager.enable = true;
    wireless.enable = lib.mkForce false;   # NM handles wifi
  };

  # Enable SSH so you can install from another machine
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Auto-login to root in the live env (standard for installers)
  services.getty.autologinUser = lib.mkForce "root";

  # Nix flakes in the ISO
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ── Installer helper script ───────────────────────────────────
  # After booting the ISO, just run `install-nixos` and follow along.
  environment.etc."install-nixos.sh" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      echo "══════════════════════════════════════════════"
      echo "  NixOS Installer"
      echo "══════════════════════════════════════════════"
      echo ""
      echo "Replace <host> below with your target machine (e.g. default, precision)."
      echo ""
      echo "1. Clone your config repo (or copy it to /mnt/etc/nixos)"
      echo "2. Edit hosts/<host>/disk-config.nix with your real disk ID"
      echo "   (run: ls -l /dev/disk/by-id/ to find it)"
      echo "3. Run disko to partition + format:"
      echo "   sudo nix run github:nix-community/disko -- \\"
      echo "     --mode disko /path/to/flake/hosts/<host>/disk-config.nix"
      echo "4. Install:"
      echo "   sudo nixos-install --flake /path/to/flake#<host>"
      echo "5. Set your password:  nixos-enter --root /mnt -c 'passwd ${userName}'"
      echo "6. Reboot and pray to the Nix gods."
      echo ""
    '';
  };

  system.stateVersion = "25.11";
}
