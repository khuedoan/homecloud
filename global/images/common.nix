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
    openssh = {
      enable = true;
    };
  };

  users.users = {
    admin = {
      isNormalUser = true;
      # Generated with mkpasswd --method=bcrypt --rounds=16
      # See ../../README.md to decrypt the password in ../init/group_vars/proxmox/vault.yaml
      initialHashedPassword = "$2b$16$1/UdSSh4cE9UbH1PG8uIt.9VutcfR.jZNiDkv.M5A4h.swYEXNOIm";
      extraGroups = [
        "wheel"
      ];
    };
  };

  system.stateVersion = "23.11";
}
