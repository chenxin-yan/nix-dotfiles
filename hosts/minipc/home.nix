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
    ../../modules/home
  ];

  home.packages = with pkgs; [
    # terminfo for xterm-ghostty so SSH sessions from Ghostty clients work
    ghostty.terminfo
  ];

  # Headless server: disable GUI apps, keep terminal/CLI tooling
  app.shared.ghostty.enable = false;
  app.shared.espanso.enable = false;
  app.shared.zen-browser.enable = false;
  app.shared.vesktop.enable = false;
  app.shared.telegram.enable = false;
  app.shared.todoist.enable = false;

  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        AddKeysToAgent = "yes";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };
    };
  };
}
