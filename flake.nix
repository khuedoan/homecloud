{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      sops-nix,
    }:
    {
      nixosConfigurations = {
        homecloud = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            ./metal/configuration.nix
            ./metal/hosts/homecloud.nix
          ];
        };
        test = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            ./metal/configuration.nix
            ./metal/hosts/test.nix
          ];
        };
      };
      devShells = {
        x86_64-linux = with nixpkgs.legacyPackages.x86_64-linux; {
          default = mkShell {
            packages = [
              age
              gnumake
              nixfmt-rfc-style
              sops
              wireguard-tools
            ];
          };
        };
      };
    };
}
