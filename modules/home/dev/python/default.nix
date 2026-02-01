{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.python.enable = lib.mkEnableOption "enables Python development tools";
  };

  config = lib.mkIf config.dev.python.enable {
    home.packages = with pkgs; [
      python313
      uv

      # editor
      ruff
      basedpyright
      python313Packages.debugpy
    ];

    programs.uv.enable = true;

    # Add ~/.local/bin to PATH for uv tool executables
    home.sessionPath = [ "$HOME/.local/bin" ];
  };
}
