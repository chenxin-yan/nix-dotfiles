{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.markdown.enable = lib.mkEnableOption "enables markdown writing and linting tools";
  };

  config = lib.mkIf config.dev.markdown.enable {
    home.packages = with pkgs; [
      mermaid-cli
      glow

      markdownlint-cli2
      prettierd
      marksman
      harper
    ];

    home.file.".markdownlint.json".source = ./config/markdownlint.jsonc;
  };
}
