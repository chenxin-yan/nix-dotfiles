{
  description = "chenxinyan dotfiles flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    catppuccin.url = "github:catppuccin/nix";

    pi-catppuccin = {
      url = "github:otahontas/pi-coding-agent-catppuccin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    herdr-micro = {
      url = "github:chenxin-yan/herdr-micro";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      catppuccin,
      pi-catppuccin,
      home-manager,
      nix-darwin,
      nix-homebrew,
      zen-browser,
      ...
    }:
    let
      darwinUser = "yanchenxin";
    in
    {
      nixosConfigurations."cyan@minipc" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/minipc/configuration.nix
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.cyan = {
                imports = [
                  ./hosts/minipc/home.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
              extraSpecialArgs = { inherit inputs darwinUser; };
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };

      darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          {
            system.primaryUser = darwinUser;

            nix-homebrew = {
              enable = true;
              enableRosetta = false;
              user = darwinUser;
              mutableTaps = true;
            };
          }
          ./hosts/darwin/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${darwinUser} = {
                imports = [
                  ./hosts/darwin/home.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
