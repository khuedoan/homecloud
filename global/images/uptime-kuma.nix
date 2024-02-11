{ config, pkgs, ... }:

{
  services = {
    uptime-kuma = {
      enable = true;
    };
  };
}
