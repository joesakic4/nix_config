# ── Host: precision ──────────────────────────────────────────────
# Dell Precision 7530 — Intel i7-8850H + NVIDIA Quadro P2000 (Pascal),
# 32 GB. Test machine. GPU strategy: PRIME "sync" (dGPU drives panel).
# Shared system config comes from ../../modules (via lib/mkHost.nix).
{ pkgs, userName, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/gpu/nvidia-prime.nix
  ];

  # Stable kernel, NOT _latest: the proprietary NVIDIA modules break
  # constantly on bleeding-edge kernels, and Pascal needs the closed
  # driver. This is the platform where you find footguns first.
  boot.kernelPackages = pkgs.linuxPackages;

  boot.loader.limine.maxGenerations = 15;

  # PRIME bus IDs for this chassis. Verify after first boot with
  # `lspci | grep -E "VGA|3D"`; if NVIDIA moved, fix here or get a
  # black screen. (open=false — Pascal is too old for open modules.)
  myGpu.nvidiaPrime = {
    intelBusId  = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Extra group for virtio-gpu / kvm passthrough work (appends to the
  # base groups in modules/users.nix).
  users.users.${userName}.extraGroups = [ "kvm" ];

  # Host-specific extras: GPU diagnostics + explicit swtpm.
  environment.systemPackages = with pkgs; [
    nvtopPackages.full   # nvtop — shows both Intel + NVIDIA
    vulkan-tools         # vulkaninfo, vkcube
    mesa-demos           # glxgears / eglinfo
    libva-utils          # vainfo — confirm VA-API
    swtpm                # explicit, in case libvirtd is ever disabled
  ];

  system.stateVersion = "25.11";
}
