{
  description = "IKSDP desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko= {
        url = "github:nix-community/disko/v1.11.0";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
        url = "github:nix-community/home-manager/release-24.11";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
        url = "github:nix-community/impermanence";
    };
    preservation = {
        url = "github:nix-community/preservation";
    };
  };

  outputs = { self, nixpkgs, disko, impermanence, preservation, home-manager, ... }@inputs: {
    nixosConfigurations = {
      pc-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { config._module.args = { flake = self; }; }
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          preservation.nixosModules.preservation
          ./computer/pc-1.nix
          ./options.nix
          ./os/default.nix
          ./software/default.nix
          ./users/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.live = import ./users/live/home/default.nix;
            };
          }
        ];
      };
      vm-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { config._module.args = { flake = self; }; }
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          preservation.nixosModules.preservation
          ./computer/vm-1.nix
          ./options.nix
          ./os/default.nix
          ./software/default.nix
          ./users/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.live = import ./users/live/home/default.nix;
            };
          }
        ];
      };
      linux-art = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          { config._module.args = { flake = self; }; }
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          preservation.nixosModules.preservation
          ./computer/linux-art/default.nix
          ./options.nix
          ./os/default.nix
          ./software/default.nix
          ./users/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.live = import ./users/live/home/default.nix;
            };
          }
        ];
      };
    };
  };
}
