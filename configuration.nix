# /etc/nixos/configuration.nix

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # ==========================================
  # Boot Loader & Kernel
  # ==========================================
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the latest stable Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==========================================
  # Networking & Hostname
  # ==========================================
  networking.hostName = "nixos-laptop"; # Define your hostname.
  networking.networkmanager.enable = true;

  # ==========================================
  # Time & Locale
  # ==========================================
  time.timeZone = "America/New_York"; # Set your time zone.
  i18n.defaultLocale = "en_US.UTF-8";

  # ==========================================
  # Desktop Environment (GNOME Example)
  # ==========================================
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ==========================================
  # Audio (PipeWire)
  # ==========================================
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ==========================================
  # User Account
  # ==========================================
  users.users.YOUR_USERNAME_HERE = {
    isNormalUser = true;
    description = "Daily Driver User";
    extraGroups = [ 
      "networkmanager" 
      "wheel"           # Enable sudo
      "docker"          # Access Docker without sudo
      "libvirtd"        # Access Virt-Manager without sudo
    ];
  };

  # ==========================================
  # Software: Unfree & System Packages
  # ==========================================
  # Allow unfree packages (Required for VSCode, Brave, proprietary drivers)
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Core Tools
    vim
    wget
    git
    htop

    # Your Requested Apps
    brave
    vscode
    # Note: If you have issues with VSCode extensions, try 'vscode-fhs' instead.

    # Virtualization Tools
    qemu_full
    virt-manager
    docker-compose
    
    # Required for Windows 11 VMs (TPM emulation)
    swtpm
    OVMFFull
  ];

  # ==========================================
  # Virtualization Configuration
  # ==========================================
  
  # 1. Docker
  virtualisation.docker.enable = true;
  # Optional: Clean up unused docker images weekly
  virtualisation.docker.autoPrune.enable = true;

  # 2. KVM / QEMU / Virt-Manager
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_full;
      runAsRoot = true;
      swtpm.enable = true; # Needed for TPM emulation (Windows 11)
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };
  
  # Enable dconf (Required for virt-manager to save settings)
  programs.dconf.enable = true;

  # Enable USB redirection (Pass USB sticks to VMs)
  virtualisation.spiceUSBRedirection.enable = true;

  # ==========================================
  # System State Version
  # ==========================================
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "23.11"; # Change this to your install version if different
}
