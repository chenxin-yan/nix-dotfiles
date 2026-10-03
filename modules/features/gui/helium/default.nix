# Helium (Chromium-based), the daily browser on both systems, with no browser
# sync: Nix carries what Chromium lets an admin set, browsing data stays on
# each machine.
#   - Policies: mandatory on Linux (/etc/chromium/policies, which Helium
#     keeps). On macOS, user defaults only count as "recommended" (Helium
#     applies them, but the UI can change them); mandatory ones need an MDM
#     profile.
#   - Extensions: External Extensions files, which Helium installs through
#     its own Web Store proxy at startup (needs Helium's services, on by
#     default).
#   - Surfingkeys reads its keymap from ./surfingkeys.js through its native
#     host (headless Neovim running the project's server.lua).
#   - Everything else (layout, toolbar, theme, Helium's own shortcuts) lives in
#     the profile's Preferences file. Each switch merges `preferences` into it
#     while Helium is closed; a UI change lasts until the next switch.
{ config, inputs, ... }:
let
  # Chrome Web Store ID → name.
  extensions = {
    aeblfdkhhhdcdjpifhhbdiojplfjncoa = "1Password";
    lnjaiaapbakfhlbjenjkhffcdpoompki = "Catppuccin for Web File Explorer Icons";
    hlepfoohegkhhmjieoechaddaejaokhf = "Refined GitHub";
    mnjggcdmjocbbbhaepdhchncahnbgone = "SponsorBlock";
    gfbliohnnapiefjpjlpjnehglfpaknnc = "Surfingkeys";
  };
  surfingkeysId = "gfbliohnnapiefjpjlpjnehglfpaknnc";

  # Only what differs from Helium's defaults (registered in its source,
  # imputnet/helium patches/helium). None of these keys is a Chromium
  # "tracked" preference, which macOS resets when edited outside the browser
  # (homepage, startup pages, search engine: set those as policies).
  # Custom shortcuts go in helium.browser.custom_accelerators, stored as
  # { "<command id>" = { added = [ … ]; removed = [ … ]; }; } (ids from
  # chrome/app/chrome_command_ids.h); copy them from Preferences after setting
  # them in Settings → Keyboard shortcuts.
  preferences = {
    helium.browser = {
      layout = 2; # vertical tabs
      vertical_right_aligned = true;
      zen_mode = true;
      zen_mode_sidebar_pinned = true;
      centered_location_bar = true;
      minimal_location_bar = true;
      mru_tab_cycling = true;
      new_tab_next_to_active = true;
      show_back_button = false;
      show_reload_button = false;
      show_dynamic_new_tab_button = false;
      show_vertical_tabs_collapse_button = false;
    };
    browser = {
      show_forward_button = false;
      theme.is_grayscale2 = true;
    };
    vertical_tabs.uncollapsed_width = 200;
  };

  # Shortcuts (Settings → Keyboard shortcuts), keyed by Chromium command id
  # (chrome/app/chrome_command_ids.h). Ctrl+S/D go back/forward on both
  # systems; Cmd+O is tab search, freeing Cmd+Shift+A.
  accelerators = {
    "33000".added = [ "Control+KeyS" ]; # IDC_BACK
    "33001".added = [ "Control+KeyD" ]; # IDC_FORWARD
  };
  # The rest names Ctrl or Cmd (Meta) per OS.
  platformAccelerators = {
    # xremap turns Cmd+<key> into Ctrl+<key> here, so Cmd+O arrives as Ctrl+O
    # and Cmd+S as Ctrl+S: on Linux Cmd+S goes back, except in web apps that
    # handle it themselves (pages see the key before Helium). Cmd+D isn't
    # translated, so it can stay Bookmark as on the Mac.
    linux = {
      "52500" = {
        # IDC_TAB_SEARCH
        added = [ "Control+KeyO" ];
        removed = [ "Control+Shift+KeyA" ];
      };
      "40000".removed = [ "Control+KeyO" ]; # IDC_OPEN_FILE
      "35004".removed = [ "Control+KeyS" ]; # IDC_SAVE_PAGE
      "35000" = {
        # IDC_BOOKMARK_THIS_TAB
        added = [ "Meta+KeyD" ];
        removed = [ "Control+KeyD" ];
      };
    };
    darwin = {
      "52500" = {
        added = [ "Meta+KeyO" ];
        removed = [ "Shift+Meta+KeyA" ];
      };
      "40000".removed = [ "Meta+KeyO" ];
    };
  };

  # https://chromeenterprise.google/policies/
  policies = {
    BrowserSignin = 0;
    SyncDisabled = true;
    # 1Password owns passwords and autofill.
    PasswordManagerEnabled = false;
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
  };
in
{
  features.helium = {
    includes = with config.features; [ paths ];

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default ];
        environment.etc."chromium/policies/managed/helium.json".text = builtins.toJSON policies;
        # 1Password's extension only talks to browsers it trusts. On macOS
        # that's approved once in 1Password → Settings → Browser.
        environment.etc."1password/custom_allowed_browsers" = {
          text = "helium\n";
          mode = "0755";
        };
      };

    darwin = {
      homebrew.casks = [ "helium-browser" ];
      system.defaults.CustomUserPreferences."net.imput.helium" = policies;
    };

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        inherit (pkgs.stdenv.hostPlatform) isLinux;
        dataDir =
          if isLinux then ".config/net.imput.helium" else "Library/Application Support/net.imput.helium";

        surfingkeysServer = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/brookhong/Surfingkeys/1812ec78e7b074d71f41fb19789135a65780339c/src/nvim/server/server.lua";
          hash = "sha256-aGGZXwjSHw08xolg0z3TblNYNbWV/DDkWxgMIiH9eww=";
        };
        # --clean: the host only serves the settings file, so skip loading the
        # whole Neovim config on every page load.
        surfingkeysHost = pkgs.writeShellScript "surfingkeys-host" ''
          exec ${lib.getExe pkgs.neovim} --clean --headless -c "luafile ${surfingkeysServer}"
        '';
      in
      {
        home.activation.heliumPreferences =
          let
            prefs = "$HOME/${dataDir}/Default/Preferences";
            pgrep = if isLinux then lib.getExe' pkgs.procps "pgrep" else "/usr/bin/pgrep";
            jq = lib.getExe pkgs.jq;
            fragment = pkgs.writeText "helium-preferences.json" (
              builtins.toJSON (
                lib.recursiveUpdate preferences {
                  helium.browser.custom_accelerators =
                    accelerators // platformAccelerators.${if isLinux then "linux" else "darwin"};
                }
              )
            );
          in
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if ${pgrep} -x '${if isLinux then "helium" else "Helium"}' >/dev/null; then
              warnEcho "Helium is running; quit it and switch again to apply its preferences."
            else
              run mkdir -p "$(dirname "${prefs}")"
              [ -f "${prefs}" ] || run sh -c 'echo "{}" > "${prefs}"'
              run sh -c '${jq} -s ".[0] * .[1]" "${prefs}" ${fragment} > "${prefs}.nix-tmp" && mv "${prefs}.nix-tmp" "${prefs}"'
            fi
          '';

        # macOS asks before changing the default browser, so only ask when it
        # isn't Helium yet.
        home.activation.heliumDefaultBrowser = lib.mkIf (!isLinux) (
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if ! ${lib.getExe pkgs.defaultbrowser} | grep -q '^\* helium$'; then
              run ${lib.getExe pkgs.defaultbrowser} helium
            fi
          ''
        );

        home.file = {
          ".surfingkeys.js".source =
            config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/features/gui/helium/surfingkeys.js";
          "${dataDir}/NativeMessagingHosts/surfingkeys.json".text = builtins.toJSON {
            name = "surfingkeys";
            description = "Surfingkeys settings from ~/.surfingkeys.js";
            path = "${surfingkeysHost}";
            type = "stdio";
            allowed_origins = [ "chrome-extension://${surfingkeysId}/" ];
          };
        }
        // lib.mapAttrs' (
          id: _:
          lib.nameValuePair "${dataDir}/External Extensions/${id}.json" {
            # Helium's stand-in for the Web Store's update URL: only that host is
            # rewritten to its proxy (services.helium.imput.net/ext). Google's own
            # URL answers "no update", since Helium leaves out the Chrome version.
            text = builtins.toJSON { external_update_url = "https://update-url-to-be-replaced.qjz9zk"; };
          }
        ) extensions;

        xdg.mimeApps = lib.mkIf isLinux {
          enable = true;
          defaultApplications = lib.genAttrs [
            "text/html"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/about"
            "x-scheme-handler/unknown"
          ] (_: "helium.desktop");
        };
      };
  };
}
