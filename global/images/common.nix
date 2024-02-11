{ config, pkgs, ... }:

{
  networking = {
    networkmanager = {
      enable = true;
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  services = {
    getty = {
      autologinUser = "root";
    };
    openssh = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
