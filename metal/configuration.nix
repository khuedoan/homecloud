{
  imports = [
    ./disks.nix
    ./incus.nix
    ./network.nix
    ./secrets.nix
    ./ssh.nix
    ./users.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  virtualisation.vmVariant = {
    users.users.admin = {
      password = "test";
    };
    virtualisation = {
      graphics = false;
      forwardPorts = [
        {
          host.port = 8443;
          guest.port = 8443;
        }
      ];
    };
  };
}
