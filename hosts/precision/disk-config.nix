# ── Declarative disk layout (disko) – Dell Precision 7530 ──────
#
# THIS WILL WIPE YOUR DISK.
#
#   sudo nix run github:nix-community/disko -- \
#     --mode disko ./hosts/precision/disk-config.nix
#
# The 7530 uses NVMe.  Disk IDs look like:
#   nvme-Samsung_SSD_970_EVO_Plus_1TB_SXXXXXXXX
#
# Layout (single NVMe, wipe-and-replace, pure UEFI):
#   ├── ESP        1 GiB    → /boot       (FAT32)
#   ├── swap       12 GiB                 (suspend-to-RAM only)
#   └── root       remainder → btrfs
#       ├── @            → /
#       ├── @home        → /home
#       ├── @nix         → /nix
#       ├── @log         → /var/log
#       └── @snapshots   → /.snapshots
#
# No BIOS boot partition — unlike the ancient ProBook, the 7530's
# UEFI is competent and doesn't need the legacy fallback.
#
# ESP is 1 GiB (not 512 MiB) because limine + multiple kernel
# generations can burn through 512 MiB faster than you'd think,
# and NVMe real-estate is cheap.
#
{ ... }:
{
  disko.devices = {
    disk.main = {
      # ⚠  Replace before installing!
      # Run:  ls -l /dev/disk/by-id/ | grep nvme
      # and paste the symlink (e.g. /dev/disk/by-id/nvme-Samsung_...)
      device = "/dev/nvme0n1";
      type   = "disk";

      content = {
        type = "gpt";
        partitions = {

          # ── EFI System Partition ──────────────────────────────
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type         = "filesystem";
              format       = "vfat";
              mountpoint   = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          # ── Swap ──────────────────────────────────────────────
          # 12 GiB — suspend-to-RAM only, NOT hibernate.
          # If you change your mind and want hibernate later,
          # bump this to 34 GiB (RAM + a few GiB buffer) and
          # re-partition.  You chose suspend-only, so 12 is plenty.
          swap = {
            size = "12G";
            content = {
              type         = "swap";
              resumeDevice = false;       # no hibernate resume
            };
          };

          # ── btrfs with subvolumes ─────────────────────────────
          root = {
            size = "100%";
            content = {
              type      = "btrfs";
              extraArgs = [ "-f" ];

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
