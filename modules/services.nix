# ── Core system services ─────────────────────────────────────────
{ ... }:
{
  services.dbus.enable    = true;
  services.openssh.enable = true;
  security.polkit.enable  = true;
}
