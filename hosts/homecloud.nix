{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/ata-CT1000MX500SSD1_2209E614C62F";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "1G";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "150G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
        incus = {
          type = "BF01";
          label = "incus";
          size = "750G";
          content = {
            type = "zfs";
            pool = "default";
          };
        };
      };
    };
  };

  disko.devices.zpool.default.type = "zpool";

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
  };

  networking = {
    hostId = "d8e2a8bb";
    useDHCP = false;
    bridges.br0.interfaces = [ "enp0s31f6" ];
    interfaces.br0 = {
      useDHCP = true;
      macAddress = "6c:4b:90:31:93:18";
    };
    dhcpcd = {
      persistent = true;
      extraConfig = "clientid";
    };
  };

  virtualisation.incus.preseed = {
    storage_pools = [
      {
        name = "default";
        driver = "zfs";
        config.source = "default";
      }
    ];
    profiles = [
      {
        name = "default";
        config."security.secureboot" = "false";
        devices = {
          eth0 = {
            name = "eth0";
            nictype = "bridged";
            parent = "br0";
            type = "nic";
          };
          root = {
            path = "/";
            pool = "default";
            type = "disk";
          };
        };
      }
    ];
  };

}
