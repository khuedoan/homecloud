{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, disko, ... }: {
    nixosConfigurations = {
      installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./installer.nix
        ];
      };
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./disks.nix
        ];
      };
    };
  };
}
