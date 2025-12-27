{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    app.shared.todoist.enable = lib.mkEnableOption "enables Todoist desktop app";
  };

  config = lib.mkIf config.app.shared.todoist.enable {
    home.packages = pkgs.lib.optionals pkgs.stdenv.isLinux (
      with pkgs;
      [
        todoist-electron
      ]
    );

    # NOTE: For macOS, added the following to the darwin configuration:
    # homebrew.casks = [ "todoist-app" ];
  };
}
