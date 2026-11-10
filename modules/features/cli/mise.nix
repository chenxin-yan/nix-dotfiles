{
  features.mise = {
    # mise's prebuilt tools are generic-Linux binaries; NixOS can only start
    # them through nix-ld (mise docs, "Building from source").
    nixos.programs.nix-ld.enable = true;

    homeManager = {
      programs.mise = {
        enable = true;
        globalConfig = {
          settings = {
            experimental = true;
            node.compile = false;
          };
        };
      };
    };
  };
}
