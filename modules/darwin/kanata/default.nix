{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    darwin.kanata.enable = lib.mkEnableOption "enables Kanata keyboard remapping daemon for nix-darwin";
  };

  config = lib.mkIf config.darwin.kanata.enable {
    environment.systemPackages = [
      pkgs.kanata
    ];

    homebrew.casks = [
      "karabiner-elements"
    ];

    launchd.daemons.kanata = {
      serviceConfig = {
        ProgramArguments = [
          "/run/current-system/sw/bin/kanata"
          "--cfg"
          "/Users/${config.system.primaryUser}/.config/kanata/kanata.kbd"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        UserName = "root";
        StandardOutPath = "/Users/${config.system.primaryUser}/Library/Logs/kanata.log";
        StandardErrorPath = "/Users/${config.system.primaryUser}/Library/Logs/kanata.error.log";
      };
    };
  };
}
