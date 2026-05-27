# ── Shared system packages ───────────────────────────────────────
# Common to every host. Host-specific extras (e.g. GPU monitoring
# tools on the precision) are appended in the host's own file —
# environment.systemPackages merges across modules.
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # ── Core CLI ──────────────────────────
    git
    curl
    wget
    unzip
    file
    htop
    btop
    ripgrep
    fd
    jq
    tree

    # ── btrfs tools ───────────────────────
    btrfs-progs
    compsize            # actual on-disk compression ratios
    snapper             # snapshot management

    # ── Wayland / Hyprland ecosystem ──────
    kitty
    waybar
    wofi
    dunst
    swww
    grim
    slurp
    wl-clipboard
    cliphist
    swaylock-effects
    brightnessctl
    playerctl

    # ── File manager / GUI ────────────────
    thunar
    firefox
    pavucontrol

    # ── Virtualisation helpers ────────────
    virt-viewer
    spice-gtk
    virtio-win          # Windows virtio drivers ISO

    # ── Power / GPU monitoring ────────────
    powertop            # analyse power usage
    intel-gpu-tools     # intel_gpu_top (both machines have an Intel iGPU)

    # ── Dev ───────────────────────────────
    neovim
    gcc
    gnumake
  ];
}
