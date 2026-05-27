# ── Virtualisation (QEMU / libvirt / virt-manager) ───────────────
{ pkgs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package      = pkgs.qemu_kvm;
        runAsRoot    = true;
        swtpm.enable = true;                # TPM 2.0 emulation (Win11)
        ovmf = {
          enable   = true;
          packages = [ pkgs.OVMFFull.fd ];  # UEFI + Secure Boot keys
        };
      };
    };
    spiceUSBRedirection.enable = true;
  };
  programs.virt-manager.enable = true;
}
