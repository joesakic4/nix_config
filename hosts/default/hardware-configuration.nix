# ── Hardware configuration – Dell Pro 16 Plus ───────────────────
# Intel Core Ultra 7 268V (Lunar Lake) · 32 GB LPDDR5x · Xe2 iGPU
#
# ⚠  STILL REPLACE this with the real output of:
#      sudo nixos-generate-config --show-hardware-config
#    This file is a *best-guess* starting point so you don't boot into
#    a black screen because the kernel couldn't find your NVMe.
#
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ── initrd modules ────────────────────────────────────────────
  # Lunar Lake NVMe + USB + Thunderbolt
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  # Load the xe GPU driver early so you get native-res console from the start
  # instead of staring at a 640x480 potato while the initrd loads.
  boot.initrd.kernelModules = [ "xe" ];

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # ── Filesystem mounts ─────────────────────────────────────────
  # Disko handles the actual partitioning, but nixos-rebuild needs
  # these declared so it knows where to mount things.
  # After running nixos-generate-config, replace the device strings
  # with the real UUIDs it discovers.
  fileSystems."/" = {
    device  = "/dev/disk/by-partlabel/root";
    fsType  = "btrfs";
    options = [ "subvol=@" "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/home" = {
    device  = "/dev/disk/by-partlabel/root";
    fsType  = "btrfs";
    options = [ "subvol=@home" "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/nix" = {
    device  = "/dev/disk/by-partlabel/root";
    fsType  = "btrfs";
    options = [ "subvol=@nix" "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/var/log" = {
    device  = "/dev/disk/by-partlabel/root";
    fsType  = "btrfs";
    options = [ "subvol=@log" "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
    neededForBoot = true;
  };

  fileSystems."/.snapshots" = {
    device  = "/dev/disk/by-partlabel/root";
    fsType  = "btrfs";
    options = [ "subvol=@snapshots" "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/boot" = {
    device  = "/dev/disk/by-partlabel/ESP";
    fsType  = "vfat";
    options = [ "umask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-partlabel/swap"; }
  ];

  # ── CPU ───────────────────────────────────────────────────────
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Intel P-state driver (Lunar Lake's hybrid P/E cores)
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
