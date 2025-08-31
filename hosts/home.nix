{
  self,
  config,
  pkgs,
  ...
}:

{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "lavender";
    zsh-syntax-highlighting.enable = false;
  };

  fonts.fontconfig.enable = true;
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono

    tlrc
    curlie
    rainfrog
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
    };
  };
}
