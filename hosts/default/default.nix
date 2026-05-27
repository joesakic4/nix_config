# ── Host: default ────────────────────────────────────────────────
# Dell Pro 16 Plus — Intel Ultra 7 268V (Lunar Lake), 32 GB, Xe2 iGPU.
# Shared system config comes from ../../modules (via lib/mkHost.nix);
# only the machine-specific knobs live here.
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/gpu/intel.nix
  ];

  # Lunar Lake needs a recent kernel for full Xe2 GPU + NPU + wifi.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.limine.maxGenerations = 20;

  system.stateVersion = "25.11";
}
