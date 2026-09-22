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
      home-manager,
      nix-darwin,
      nix-homebrew,
      ...
    }:
    let
      lib = nixpkgs.lib;
      hosts = import ./hosts;

      # Facts every registered target shares: hostname = inventory key,
      # platform from inventory, integrated Home Manager for the host login.
      # Host modules receive their inventory entry as `host`; home modules
      # receive the whole inventory as `hosts` for managed-peer facts.
      hostModule = name: host: {
        networking.hostName = name;
        nixpkgs.hostPlatform = host.system;
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [ catppuccin.homeModules.catppuccin ];
          users.${host.login}.imports = [ ./hosts/${name}/home.nix ];
          extraSpecialArgs = { inherit inputs hosts; };
        };
      };

      darwinHost =
        name: host:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs host; };
          modules = [
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager
            ./hosts/${name}/configuration.nix
            (hostModule name host)
            {
              system.primaryUser = host.login;
              nix-homebrew = {
                enable = true;
                enableRosetta = false;
                user = host.login;
                mutableTaps = true;
              };
            }
          ];
        };

      nixosHost =
        name: host:
        lib.nixosSystem {
          specialArgs = { inherit inputs host; };
          modules = [
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            ./hosts/${name}/configuration.nix
            (hostModule name host)
          ];
        };

      hostsOn = suffix: lib.filterAttrs (_: host: lib.hasSuffix suffix host.system) hosts;
      darwinConfigurations = lib.mapAttrs darwinHost (hostsOn "-darwin");
      nixosConfigurations = lib.mapAttrs nixosHost (hostsOn "-linux");
      configurations = darwinConfigurations // nixosConfigurations;
    in
    {
      inherit darwinConfigurations nixosConfigurations;

      hosts = lib.mapAttrs (
        name: host:
        let
          cfg = configurations.${name}.config;
        in
        host
        // {
          uid = cfg.users.users.${host.login}.uid;
          dotfiles = cfg.home-manager.users.${host.login}.dotfiles;
        }
      ) hosts;
    };
}
