{
  config,
  lib,
  pkgs,
  ...
}:
{
  virtualisation = {
    incus = {
      enable = true;
      ui = {
        enable = true;
      };
      preseed = {
        config = {
          "core.https_address" = "[::]:8443";
        };
        storage_pools = [
          {
            name = "default";
            driver = "btrfs";
            config = {
              size = "35GiB";
            };
          }
        ];
        networks = [
          {
            name = "incusbr0";
            type = "bridge";
            config = {
              "ipv4.address" = "auto";
              "ipv6.address" = "auto";
            };
          }
        ];
        profiles = [
          {
            name = "default";
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
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
    };
  };
}
