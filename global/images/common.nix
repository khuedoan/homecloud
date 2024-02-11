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

  environment.systemPackages = with pkgs; [
    git
    gnumake
    neovim
  ];

  programs = {
    direnv = {
      enable = true;
      silent = true;
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

  virtualisation = {
    docker = {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
