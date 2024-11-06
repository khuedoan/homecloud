{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
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
          modules = [ ./metal/configuration.nix ];
        };
      };
    });
}
