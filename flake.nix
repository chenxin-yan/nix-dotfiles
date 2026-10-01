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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Raspberry Pi 5 board support. Keeps its own nixpkgs: the board module
    # takes the kernel and firmware from it, which nixos-raspberrypi.cachix.org
    # has prebuilt.
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/v1.20260801.0";

    hermes-agent.url = "github:NousResearch/hermes-agent/da2f473bdbfdac58ddebabd8bdf76ddb2b42fb35";

    nix-dokploy = {
      url = "github:el-kurto/nix-dokploy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
