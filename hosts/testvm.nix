{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  networking = {
    hostName = lib.mkForce "testvm";
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
  };
  services.getty.autologinUser = "admin";
  security.sudo.wheelNeedsPassword = false;
}
