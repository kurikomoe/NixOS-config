{...}: let
  vpsDisk = "/dev/sda";
in {
  disko = {
    devices = {
      disk.main = {
        imageSize = "3G";
        device = vpsDisk;
        type = "disk";

        content = {
          type = "gpt";

          partitions = {
            boot = {
              # sda1
              priority = 0;
              size = "1M";
              type = "EF02"; # for grub MBR
            };

            ESP = {
              # sda2
              priority = 1;
              name = "ESP";
              size = "1G"; #!FIXME do not make it too small
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };

            nix = {
              # sda3
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                # extraArgs = ["-f"];
                mountpoint = "/";
                mountOptions = ["compress=zstd" "noatime" "nosuid" "nodev"];
              };
            };
          };
        };
      };
    };

    enableConfig = false;
  };
}
