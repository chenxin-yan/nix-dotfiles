{
  features.todoist.homeManager =
    { pkgs, ... }:
    {
      home.packages = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux (
        with pkgs;
        [
          todoist-electron
        ]
      );

      # NOTE: For macOS, added the following to the darwin configuration:
      # homebrew.casks = [ "todoist-app" ];
    };
}
