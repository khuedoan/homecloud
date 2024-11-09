{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./disks.nix
    ./users.nix
    ./incus.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "24.05"; # Did you read the comment?
}
