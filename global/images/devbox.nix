{ config, pkgs, ... }:

{
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

  virtualisation = {
    docker = {
      enable = true;
    };
  };
}
