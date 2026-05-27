# ── Laptop power + firmware ──────────────────────────────────────
# thermald + power-profiles-daemon (don't also enable TLP — they fight).
{ ... }:
{
  services.thermald.enable              = true;
  services.power-profiles-daemon.enable = true;

  # Firmware updates (Dell supports fwupd)
  services.fwupd.enable = true;

  # Redistributable firmware blobs (GuC/HuC/DMC, sof-firmware, wifi, …)
  hardware.enableRedistributableFirmware = true;
}
