{
  config,
  hosts,
  pkgs,
  ...
}:

{
  imports = [
    ../../profiles/home/base.nix
    ../../profiles/home/development.nix
  ];

  home.stateVersion = "25.05";

  cli.syncthing.enable = true;

  home.packages = with pkgs; [
    # terminfo for xterm-ghostty so SSH sessions from Ghostty clients work
    ghostty.terminfo
  ];

  services.ssh-agent.enable = true;

  home.file.".ssh/known_hosts.d/cyan-macbook".text =
    "cyan-macbook ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWPwldEec8fXHXQVExXb+Wix89Sxs5fOxxYCrShl+aI";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        AddKeysToAgent = "yes";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };

      "cyan-macbook" = {
        User = hosts.macbook.login;
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
        CheckHostIP = false;
        UserKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts.d/cyan-macbook ${config.home.homeDirectory}/.ssh/known_hosts";
      };
    };
  };
}
