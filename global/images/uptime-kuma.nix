{ config, pkgs, ... }:

{
  services = {
    uptime-kuma = {
      enable = true;
      settings = {
        UPTIME_KUMA_HOST = "0.0.0.0";
      };
    };
  };
}
