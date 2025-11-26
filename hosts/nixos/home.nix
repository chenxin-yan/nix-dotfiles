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

  catppuccin.cursors.enable = true;

  # gnome-keyring SSH agent integration
  services.gnome-keyring = {
    enable = true;
    components = [
      "secrets"
      "ssh"
    ];
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
