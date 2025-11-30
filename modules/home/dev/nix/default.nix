{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.nix.enable = lib.mkEnableOption "enables Nix development tools";
  };

  config = lib.mkIf config.dev.nix.enable {
    home.packages = with pkgs; [
      nil
      nixfmt-rfc-style
      nixfmt-tree
    ];
  };
}
