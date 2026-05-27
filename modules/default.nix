# ── Shared system modules ────────────────────────────────────────
# Imported once per host via lib/mkHost.nix. Everything here applies
# to EVERY machine. Hardware- and GPU-specific bits live in the host
# files (hosts/<name>/default.nix) and modules/gpu/*.
#
{ ... }:
{
  imports = [
    ./nix-settings.nix
    ./boot.nix
    ./locale.nix
    ./users.nix
    ./networking.nix
    ./desktop.nix
    ./audio.nix
    ./power.nix
    ./virtualisation.nix
    ./packages.nix
    ./services.nix
  ];
  # NOTE: gpu/* is intentionally NOT imported here — each host selects
  # its own GPU module.
}
