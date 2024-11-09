{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.users.admin = {
    isNormalUser = true;
    description = "Admin";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      neovim
      git
    ];
  };
}
