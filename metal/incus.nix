{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking = {
    nftables = {
      enable = true;
    };
    firewall = {
      allowedTCPPorts = [ 8443 ];
    };
  };
  virtualisation = {
    incus = {
      enable = true;
      ui = {
        enable = true;
      };
    };
  };
}
