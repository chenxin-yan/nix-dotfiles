{
  features.todoist = {
    # nixpkgs' todoist-electron is Linux-only; the Mac app comes from Homebrew.
    darwin.homebrew.casks = [ "todoist-app" ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.todoist-electron ];
      };
  };
}
