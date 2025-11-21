{
  config,
  pkgs,
  ...
}:

{
  home.username = "cyan";
  home.homeDirectory = "/home/cyan";

  imports = [
    ../home.nix
    ../../modules
  ];

  # Keychain for SSH key management across sessions
  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    keys = [ "id_ed25519" ];
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        addKeysToAgent = "yes";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };
    };
  };
}
