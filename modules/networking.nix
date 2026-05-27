# ── Networking + Bluetooth ───────────────────────────────────────
{ hostName, ... }:
{
  networking = {
    hostName              = hostName;
    networkmanager.enable = true;
    firewall.enable       = true;
  };

  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;   # GUI for bluetooth
}
