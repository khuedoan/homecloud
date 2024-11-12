{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops = {
    defaultSopsFile = ../secrets/metal.yaml;
    age = {
      keyFile = "/root/.config/sops/age/keys.txt";
    };
    secrets = {
      wireguard_private_key = { };
    };
  };
}
