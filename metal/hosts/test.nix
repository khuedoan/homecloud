{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
  ];

  disko.devices.disk.main.device = "/dev/sda";
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
    sharedDirectories = {
      age = {
        # TODO this requires impure and hard coded path
        source = "/home/khuedoan/.config/sops/age";
        target = "/root/.config/sops/age";
      };
    };
  };
}
