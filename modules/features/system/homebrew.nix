{
  # Both Macs deliberately remove unlisted Homebrew packages and associated
  # cask data; include everything to retain in the effective Homebrew config.
  features.homebrew.darwin.homebrew = {
    enable = true;
    brews = [
      "mole"
    ];
    onActivation = {
      cleanup = "zap";
    };
  };
}
