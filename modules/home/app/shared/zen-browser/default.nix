{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  options = {
    app.shared.zen-browser = {
      enable = lib.mkEnableOption "enables Zen Browser";

    };
  };

  config = lib.mkIf config.app.shared.zen-browser.enable {
    programs.firefox.darwinDefaultsId = "app.zen-browser.zen.plist";

    programs.zen-browser = {
      enable = true;

      policies = {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };
    };
  };
}
