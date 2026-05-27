# ── Hardware configuration – Dell Precision 7530 ────────────────
# Merged from nixos-generate-config output + disko mount declarations
#
# CPU:    Intel i7-8850H (Coffee Lake, 6c/12t)
# RAM:    32 GB
# iGPU:   Intel UHD 630 (Kaby Lake-class, Gen 9.5)
# dGPU:   NVIDIA Quadro P2000 (GP106, Pascal)
# Disk:   NVMe (slot 1)
#
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ── initrd modules ────────────────────────────────────────────
  # NVMe + xhci are the minimum to read the root disk and USB
  # on this platform.  thunderbolt is here because the 7530 has
  # a TB3 port and some nvidia-powered docks attach via TB.
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"          # SATA bay may still present; harmless if unused
    "usb_storage"
    "sd_mod"
    "thunderbolt"
  ];

  # Early KMS for i915 (iGPU) — give the console native res from
  # boot.  We do NOT load nvidia in initrd: doing so makes early-
  # boot KMS fights more likely.  The NVIDIA module loads later
  # via boot.kernelModules.
  boot.initrd.kernelModules = [ "i915" ];

  # NVIDIA modules loaded after initrd, in the right order.
  boot.kernelModules = [
    "kvm-intel"
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];
  boot.extraModulePackages = [ ];

  # ── Filesystem mounts (managed by disko — don't duplicate) ────
  fileSystems."/" = {
    device  = lib.mkForce "/dev/disk/by-partlabel/root";
    fsType  = "btrfs";
    options = [ "subvol=@" "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/home" = {
    device  = lib.mkForce "/dev/disk/by-partlabel/root";
    fsType  = "btrfs";
    options = [ "subvol=@home" "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/nix" = {
    device  = lib.mkForce "/dev/disk/by-partlabel/root";
    fsType  = "btrfs";
    options = [ "subvol=@nix" "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/var/log" = {
    device  = lib.mkForce "/dev/disk/by-partlabel/root";
    fsType  = "btrfs";
    options = [ "subvol=@log" "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
    neededForBoot = true;
  };

  fileSystems."/.snapshots" = {
    device  = lib.mkForce "/dev/disk/by-partlabel/root";
    fsType  = "btrfs";
    options = [ "subvol=@snapshots" "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/boot" = {
    device  = lib.mkForce "/dev/disk/by-partlabel/ESP";
    fsType  = "vfat";
    options = [ "umask=0077" ];
  };

  swapDevices = [
    { device = lib.mkForce "/dev/disk/by-partlabel/swap"; }
  ];

  # ── CPU ───────────────────────────────────────────────────────
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # On a mobile workstation with the dGPU always on, "powersave"
  # is fine for the CPU governor.  thermald + p-p-d handle
  # ramping under load.
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
