# ── Declarative disk layout (disko) ──────────────────────────────
#
# THIS WILL WIPE YOUR DISK.  Read twice, run once.
#
#   sudo nix run github:nix-community/disko -- --mode disko ./hosts/default/disk-config.nix
#
# Layout on a Dell Pro 16 Plus NVMe:
#   ├── ESP    512 MiB  → /boot        (FAT32)
#   ├── swap   34 GiB                  (≥ RAM for hibernate)
#   └── root   remainder → btrfs
#       ├── @            → /
#       ├── @home        → /home
#       ├── @nix         → /nix        (huge on NixOS, keep isolated)
#       ├── @log         → /var/log    (survives rollbacks)
#       └── @snapshots   → /.snapshots
#
{ ... }:
{
  disko.devices = {
    disk.main = {
      # ⚠  Run: ls -l /dev/disk/by-id/ | grep nvme
      # Look for something like: nvme-SKHynix_HFS512GDE9X084N_XXXXXXXXXX
      device = "/dev/disk/by-id/nvme-PC_SN5000S_SanDisk_512GB_2547A8402154";
      type   = "disk";

      content = {
        type = "gpt";
        partitions = {

          # ── EFI System Partition ──────────────────────────────
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type       = "filesystem";
              format     = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          # ── Swap (34G — covers 32GB RAM + headroom for hibernate) ─
          swap = {
            size = "34G";
            content = {
              type          = "swap";
              resumeDevice  = true;
            };
          };

          # ── btrfs with subvolumes ─────────────────────────────
          root = {
            size = "100%";
            content = {
              type       = "btrfs";
              extraArgs  = [ "-f" ];

              subvolumes = {
                "@" = {
                  mountpoint   = "/";
                  mountOptions = [ "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
                };
                "@home" = {
                  mountpoint   = "/home";
                  mountOptions = [ "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
                };
                "@nix" = {
                  mountpoint   = "/nix";
                  mountOptions = [ "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
                };
                "@log" = {
                  mountpoint   = "/var/log";
                  mountOptions = [ "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
                };
                "@snapshots" = {
                  mountpoint   = "/.snapshots";
                  mountOptions = [ "compress=zstd:1" "noatime" "discard=async" "space_cache=v2" ];
                };
              };
            };
          };

        };
      };
    };
  };
}
