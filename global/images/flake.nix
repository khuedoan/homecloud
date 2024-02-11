{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, ... }: {
    packages.x86_64-linux = {
      base = nixos-generators.nixosGenerate {
        format = "proxmox-lxc";
        system = "x86_64-linux";
        modules = [
          ./common.nix
        ];
      };
      devbox = nixos-generators.nixosGenerate {
        format = "proxmox-lxc";
        system = "x86_64-linux";
        modules = [
          ./common.nix
          ./devbox.nix
        ];
      };
    };
  };
}
