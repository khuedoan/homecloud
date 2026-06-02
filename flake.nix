{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-26.05";
    };
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
        tinycloud = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./configuration.nix
          ];
        };
        testvm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            ./configuration.nix
            ./hosts/testvm.nix
          ];
        };
      };
      devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system: {
        default =
          with nixpkgs.legacyPackages.${system};
          mkShell {
            packages = [
              gnumake
              incus
              nixfmt-tree
              nixos-anywhere
            ];
          };
      });
    };
}
