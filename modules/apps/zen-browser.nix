{ inputs, ... }:
{
  features.zen-browser.homeManager = {
    imports = [
      inputs.zen-browser.homeModules.beta
    ];

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
