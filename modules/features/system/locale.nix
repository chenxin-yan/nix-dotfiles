{
  # Fix macOS locale issue (BCP 47 format incompatible with Unix tools)
  features.locale.darwin.environment.variables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
}
