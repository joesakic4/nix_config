# ── GPU: NVIDIA + Intel hybrid (PRIME sync) ──────────────────────
# Reusable across any Optimus/PRIME laptop. The dGPU renders
# everything and drives the panel; the iGPU stays present but unused.
# Set the per-machine knobs in the host file:
#
#   myGpu.nvidiaPrime = {
#     intelBusId  = "PCI:0:2:0";   # from `lspci | grep -E "VGA|3D"`
#     nvidiaBusId = "PCI:1:0:0";
#     open        = false;         # true only on Turing (RTX 2000) or newer
#   };
#
{ config, pkgs, lib, ... }:
let
  cfg = config.myGpu.nvidiaPrime;
in
{
  options.myGpu.nvidiaPrime = {
    intelBusId = lib.mkOption {
      type    = lib.types.str;
      example = "PCI:0:2:0";
      description = "Bus ID of the Intel iGPU (lspci, converted to PCI:b:d:f).";
    };
    nvidiaBusId = lib.mkOption {
      type    = lib.types.str;
      example = "PCI:1:0:0";
      description = "Bus ID of the NVIDIA dGPU.";
    };
    open = lib.mkOption {
      type    = lib.types.bool;
      default = false;
      description = ''
        Use the open-source kernel modules. Only valid on Turing
        (RTX 2000 / GTX 1650 refresh) or newer — Pascal and older
        must stay on the closed driver (false).
      '';
    };
  };

  config = {
    # NVIDIA DRM modesetting is mandatory for Wayland; fbdev=1 keeps
    # the console on the NVIDIA framebuffer (no black screen between
    # initrd and the compositor).
    boot.kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];

    # XWayland still reads videoDrivers, so "nvidia" is needed here.
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      modesetting.enable          = true;
      powerManagement.enable      = false;   # keep off on sync mode
      powerManagement.finegrained = false;
      open                        = cfg.open;
      nvidiaSettings              = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        sync.enable = true;
        intelBusId  = cfg.intelBusId;
        nvidiaBusId = cfg.nvidiaBusId;
      };
    };

    hardware.graphics = {
      enable = true;
      # iGPU media stack still installed so HW video decode works if
      # something explicitly targets the Intel side.
      extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt
        libvdpau-va-gl
      ];
    };

    # Magic incantations that make Hyprland actually render on NVIDIA.
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME         = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      GBM_BACKEND               = "nvidia-drm";
      NVD_BACKEND               = "direct";
      # WLR_NO_HARDWARE_CURSORS = "1";  # uncomment if cursor glitches
    };
  };
}
