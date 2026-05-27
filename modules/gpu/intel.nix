# ── GPU: Intel (Xe / Xe2, modesetting) ───────────────────────────
# Lunar Lake uses the `xe` kernel driver natively; the modesetting
# DDX + Mesa handle userspace. Imported by hosts with an Intel-only
# graphics stack.
{ pkgs, ... }:
{
  services.xserver.videoDrivers = [ "modesetting" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver    # VA-API HW video decode/encode (iHD)
      vpl-gpu-rt            # oneVPL / QSV runtime
      intel-compute-runtime # OpenCL + Level Zero (compute)
    ];
  };

  # Force the modern iHD VA-API backend, not the ancient i965.
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
}
