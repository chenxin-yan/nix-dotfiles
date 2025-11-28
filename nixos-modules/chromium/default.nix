{
  lib,
  config,
  pkgs,
  ...
}:

{
  options = {
    nixos.chromium.enable = lib.mkEnableOption "enables Chromium browser";
  };

  config = lib.mkIf config.nixos.chromium.enable {
    programs.chromium = {
      enable = true;
      extraOpts = {
        # Enable hardware acceleration
        "VaapiVideoDecodeLinuxGL" = true;
        "VaapiVideoEncoder" = true;
        "WebRTCPipeWireCapturer" = true;

        # Privacy & Security
        "BrowserSignin" = 0;
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [
          "en-US"
        ];

        # Default search engine
        "DefaultSearchProviderEnabled" = true;
        "DefaultSearchProviderName" = "DuckDuckGo";
        "DefaultSearchProviderSearchURL" = "https://duckduckgo.com/?q={searchTerms}";
      };
    };

    # Enable Wayland support
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
