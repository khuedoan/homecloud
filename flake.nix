{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-26.05";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixie = {
      url = "github:khuedoan/nixie";
    };
  };

  outputs =
    {
      nixpkgs,
      disko,
      nixie,
      ...
    }:
    {
      nixosConfigurations = {
        installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixie.nixosModules.nixie-agent
            ./hosts/installer.nix
          ];
        };
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
              nixie.packages.${system}.default
              nixos-anywhere
            ];
          };
      });
    };
}
