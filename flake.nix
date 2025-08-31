{
  description = "chenxinyan dotfiles flake";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      nixpkgs,
      catppuccin,
      home-manager,
      nix-darwin,
      ...
    }:
    {
      homeConfigurations."chenxinyan@linux-arm64" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          config.allowUnfree = true;
        };
        modules = [
          ./hosts/linux/home.nix
          ./modules/shared
          catppuccin.homeModules.catppuccin
        ];
      };

      darwinConfigurations."chenxinyan@darwin" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/darwin/configuration.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.config.allowUnfree = true;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.yanchenxin = {
                imports = [
                  ./hosts/darwin/home.nix
                  ./modules/shared
                  catppuccin.homeModules.catppuccin
                ];
              };
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };
    };
}
