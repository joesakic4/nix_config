# ── Boot + filesystem basics ─────────────────────────────────────
# Limine (EFI) bootloader and btrfs root support. `maxGenerations`
# is left to each host (cosmetic, varies per machine).
{ ... }:
{
  boot.loader.limine = {
    enable     = true;
    efiSupport = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # NOTE: KVM modules (kvm-intel / kvm-amd) are declared per-machine in
  # each hosts/<name>/hardware-configuration.nix, keeping this shared
  # layer CPU-vendor-neutral.

  # btrfs support in initrd for the root mount
  boot.supportedFilesystems = [ "btrfs" ];

  # Periodic scrub to catch bit-rot before it eats your data
  services.btrfs.autoScrub = {
    enable      = true;
    interval    = "monthly";
    fileSystems = [ "/" ];
  };
}
