{
  description = "chenxinyan dotfiles flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # TODO: remove with the overlay in modules/features/cli/yazi/default.nix.
    nixpkgs-clipboard-jh.url = "github:nixos/nixpkgs/f45c6f04c2f013f004bf94e284e95d72898d9393";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";

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

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Secure Boot for the Framework; pinned to a release, as upstream advises.
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Raspberry Pi 5 board support. Keeps its own nixpkgs: the board module
    # takes the kernel and firmware from it, which nixos-raspberrypi.cachix.org
    # has prebuilt. Its README recommends main as the stable branch.
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    hermes-agent.url = "github:NousResearch/hermes-agent";

    # nixpkgs has 0.7.0, which predates the agent features; Neovim pane
    # navigation is on main only (after v0.8.5).
    tuios = {
      url = "github:Gaurav-Gosain/tuios";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    nix-dokploy = {
      url = "github:el-kurto/nix-dokploy";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Helium isn't in nixpkgs; this repackages its official Linux .deb and is
    # bumped by a bot. The Mac gets the Homebrew cask instead.
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs has a stale 0.6.x with no NixOS module; upstream's flake ships
    # the package, udev rules and the agent user service. Linux only: the
    # Mac gets the Homebrew cask instead.
    openlogi = {
      url = "github:AprilNEA/OpenLogi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
