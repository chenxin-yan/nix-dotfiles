# Host inventory and system constructors. Each modules/hosts/<name> file
# registers one machine under `hosts.<name>`; the key is the flake target and
# the managed hostname.
{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (inputs)
    nixpkgs
    catppuccin
    home-manager
    nix-darwin
    nix-homebrew
    ;

  # Plain facts without the modules: the `hosts` flake output that
  # scripts/utils/switch.sh reads, and the `host`/`hosts` module arguments.
  hosts = lib.mapAttrs (_: host: { inherit (host) system login; }) config.hosts;

  # Facts every registered target shares: hostname = inventory key,
  # platform from inventory, integrated Home Manager for the host login.
  # Host modules receive their inventory entry as `host`; home modules
  # receive the whole inventory as `hosts` for managed-peer facts.
  # The inventory key owns the hostname, so an imported installer
  # configuration's own networking.hostName cannot override it.
  hostModule = name: host: {
    networking.hostName = lib.mkForce name;
    nixpkgs.hostPlatform = host.system;
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        catppuccin.homeModules.catppuccin
        config.flake.modules.homeManager.features
      ];
      users.${host.login}.imports = [ config.hosts.${name}.home ];
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
        config.flake.modules.darwin.features
        config.hosts.${name}.configuration
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
    nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs host; };
      modules = [
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        config.flake.modules.nixos.features
        config.hosts.${name}.configuration
        (hostModule name host)
      ];
    };

  hostsOn = suffix: lib.filterAttrs (_: host: lib.hasSuffix suffix host.system) hosts;
  darwinConfigurations = lib.mapAttrs darwinHost (hostsOn "-darwin");
  nixosConfigurations = lib.mapAttrs nixosHost (hostsOn "-linux");
  configurations = darwinConfigurations // nixosConfigurations;
in
{
  # Every feature file adds its per-class half to flake.modules.<class>.features;
  # all hosts import all features, and profiles pick them with enable flags.
  imports = [ inputs.flake-parts.flakeModules.modules ];

  options.hosts = lib.mkOption {
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          system = lib.mkOption {
            type = lib.types.enum config.systems;
            description = "Platform; `*-darwin` builds nix-darwin, `*-linux` builds NixOS.";
          };
          login = lib.mkOption {
            type = lib.types.str;
            description = "Primary user, managed by integrated Home Manager.";
          };
          configuration = lib.mkOption {
            type = lib.types.deferredModule;
            default = { };
            description = "nix-darwin or NixOS module for this host.";
          };
          home = lib.mkOption {
            type = lib.types.deferredModule;
            default = { };
            description = "Home Manager module for the login user.";
          };
        };
      }
    );
  };

  config.flake = {
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
