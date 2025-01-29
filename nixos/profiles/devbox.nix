{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fzf
    git
    gnumake
    jq
    neovim
    ripgrep
    tmux
    tree
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

  users.users = {
    admin = {
      extraGroups = [
        "docker"
      ];
    };
  };
}
