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

    homebrew-daytona = {
      url = "github:daytonaio/homebrew-cli";
      flake = false;
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hunk = {
      url = "github:modem-dev/hunk";
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
      hunk,
      homebrew-daytona,
      ...
    }:
    {
      nixosConfigurations."cyan@nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos/configuration.nix
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.cyan = {
                imports = [
                  ./hosts/nixos/home.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };

      darwinConfigurations."yanchenxin@darwin" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = false;
              user = "yanchenxin";
              mutableTaps = true;
              taps = {
                "daytonaio/homebrew-cli" = homebrew-daytona;
              };
            };
          }
          ./hosts/darwin/configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.yanchenxin = {
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
