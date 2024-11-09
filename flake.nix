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
    flake-utils.lib.eachDefaultSystem (system: {
      devShells.default =
        with nixpkgs.legacyPackages.${system};
        mkShell {
          packages = [
            gnumake
            kubectl
            nixfmt-rfc-style
          ];
        };

      nixosConfigurations = {
        homecloud-0 = nixpkgs.lib.nixosSystem {
          system = "${system}";
          modules = [
            disko.nixosModules.disko
            ./metal/configuration.nix
            ./metal/disk.nix
            { disko.devices.disk.main.device = "/dev/vda"; }
          ];
        };
      };
    });
}
