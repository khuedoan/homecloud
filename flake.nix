{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      disko,
    }:
    {
      nixosConfigurations = {
        homecloud = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./metal/configuration.nix
            { disko.devices.disk.main.device = "/dev/sda"; }
          ];
        };
        test = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./metal/configuration.nix
            ./metal/hosts/test.nix
          ];
        };
      };
    };
}
