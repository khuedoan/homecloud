{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
    }:
    {
      nixosConfigurations = {
        homecloud = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./metal/configuration.nix
            ./metal/hosts/homecloud.nix
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
      devShells = {
        x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; {
          default = mkShell {
            packages = [
              gnumake
              nixfmt-rfc-style
            ];
          };
        };
      };
    };
}
