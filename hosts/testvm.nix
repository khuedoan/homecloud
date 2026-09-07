{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  networking = {
    hostName = lib.mkForce "testvm";
    firewall.trustedInterfaces = [ "incusbr0" ];
    networkmanager.enable = true;
  };

  virtualisation.incus.preseed = {
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
    storage_pools = [
      {
        name = "default";
        driver = "btrfs";
      }
    ];
    profiles = [
      {
        name = "default";
        config."security.secureboot" = "false";
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

  virtualisation = {
    cores = 2;
    memorySize = 8192;
    diskSize = 256 * 1024;
    qemu = {
      options = [
        "-nographic"
      ];
    };
    forwardPorts = [
      {
        from = "host";
        host.port = 4646;
        guest.port = 4646;
      }
      {
        from = "host";
        host.port = 8443;
        guest.port = 8443;
      }
    ];
  };

  users.users.admin = {
    password = "testvm";
    extraGroups = [ "networkmanager" ];
  };
  services.getty.autologinUser = "admin";
  security.sudo.wheelNeedsPassword = false;
}
