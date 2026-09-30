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
    home-manager
    nix-darwin
    nix-homebrew
    ;

  # Plain facts without the modules: the `hosts` flake output that
  # scripts/utils/switch.sh reads, and the `host` module argument.
  hosts = lib.mapAttrs (_: host: { inherit (host) system login; }) config.hosts;

  # The host's own module of one class, then its selected features' (see
  # features.nix). A host sets the same class keys a feature does.
  classModules =
    class: name: [ config.hosts.${name}.${class} ] ++ map (f: f.${class}) config.hosts.${name}.selected;

  # Facts every registered target shares: hostname = inventory key,
  # platform from inventory, integrated Home Manager for the host login.
  # System modules receive their inventory entry as `host`; anything else
  # (inputs, other hosts) is read from the top-level config by closure.
  # The inventory key owns the hostname, so an imported installer
  # configuration's own networking.hostName cannot override it.
  hostModule = name: host: {
    _module.args.host = host;
    networking.hostName = lib.mkForce name;
    nixpkgs.hostPlatform = host.system;
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${host.login}.imports = classModules "homeManager" name;
    };
  };

  darwinHost =
    name: host:
    nix-darwin.lib.darwinSystem {
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager
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
      ]
      ++ classModules "darwin" name;
    };

  nixosHost =
    name: host:
    nixpkgs.lib.nixosSystem {
      modules = [
        home-manager.nixosModules.home-manager
        (hostModule name host)
      ]
      ++ classModules "nixos" name;
    };

  hostsOn = suffix: lib.filterAttrs (_: host: lib.hasSuffix suffix host.system) hosts;
  darwinConfigurations = lib.mapAttrs darwinHost (hostsOn "-darwin");
  nixosConfigurations = lib.mapAttrs nixosHost (hostsOn "-linux");
  configurations = darwinConfigurations // nixosConfigurations;
in
{
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
          darwin = lib.mkOption {
            type = lib.types.deferredModule;
            default = { };
            description = "nix-darwin module for this host; used when `system` is `*-darwin`.";
          };
          nixos = lib.mkOption {
            type = lib.types.deferredModule;
            default = { };
            description = "NixOS module for this host; used when `system` is `*-linux`.";
          };
          homeManager = lib.mkOption {
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
        # `nix eval .#hosts.<name>.features` answers "is X on for this host?"
        features = map (f: f.name) config.hosts.${name}.selected;
      }
    ) hosts;
  };
}
