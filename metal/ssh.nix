{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.openssh = {
    enable = true;
  };
}
