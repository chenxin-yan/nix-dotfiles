# Pre-dendritic host wiring, moved verbatim from flake.nix. It shrinks as
# features move into modules/ and is deleted with legacy/.
{ inputs, ... }:
let
  inherit (inputs)
    nixpkgs
    catppuccin
    home-manager
    nix-darwin
    nix-homebrew
    ;
  lib = nixpkgs.lib;
  hosts = import ../../legacy/hosts;

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
      sharedModules = [ catppuccin.homeModules.catppuccin ];
      users.${host.login}.imports = [ ../../legacy/hosts/${name}/home.nix ];
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
        ../../legacy/hosts/${name}/configuration.nix
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
        ../../legacy/hosts/${name}/configuration.nix
        (hostModule name host)
      ];
    };

  hostsOn = suffix: lib.filterAttrs (_: host: lib.hasSuffix suffix host.system) hosts;
  darwinConfigurations = lib.mapAttrs darwinHost (hostsOn "-darwin");
  nixosConfigurations = lib.mapAttrs nixosHost (hostsOn "-linux");
  configurations = darwinConfigurations // nixosConfigurations;
in
{
  flake = {
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
