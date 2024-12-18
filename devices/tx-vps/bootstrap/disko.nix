{...}: {
  disko = {
    devices = {
      disk.main = {
        imageSize = "3G";
        device = "/dev/vda";
        type = "disk";

        content = {
          type = "gpt";

          partitions = {
            boot = {
              priority = 0;
              size = "1M";
              type = "EF02"; # for grub MBR
            };

            ESP = {
              priority = 1;
              name = "ESP";
              size = "128M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };

            nix = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                # extraArgs = ["-f"];
                mountpoint = "/";
                mountOptions = ["compress=zstd" "noatime"];
                # mountOptions = ["noatime"];
              };
            };
          };
        };
      };
    };

    enableConfig = false;
  };
}
