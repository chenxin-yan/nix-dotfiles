{ inputs, ... }:
{
  features.logitech = {
    darwin.homebrew.casks = [ "openlogi" ];

    # The module owns the agent unit and its graphical-session enablement.
    nixos = {
      imports = [ inputs.openlogi.nixosModules.default ];
      programs.openlogi.enable = true;
    };

    # config.toml is a read-only store file: the GUI can't save changes
    # (it rolls them back and shows an error), so settings change here.
    homeManager =
      { lib, pkgs, ... }:
      let
        capabilities = {
          backlight = false;
          buttons = true;
          dpi_gestures = true;
          easy_switch = true;
          fn_lock = false;
          haptic_feedback = false;
          haptic_panel = false;
          hires_wheel = true;
          lighting = false;
          os_layout = false;
          pointer = true;
          report_rate = false;
          scroll_inversion = true;
          thumbwheel = true;
          virtual_thumbwheel = false;
        };

        settings = {
          schema_version = 8;
          selected_device = "serial:2312ap01jmr8";
          keyboard = { };

          app_settings = {
            launch_at_login = !pkgs.stdenv.hostPlatform.isLinux;
            app_icon = "openlogi";
            appearance = "system";
            asset_source = "automatic";
            auto_download_assets = true;
            auto_install_updates = false;
            capture_mouse_events = true;
            check_for_updates = false;
            device_view_mode = "grid";
            mouse_profile_target = "pointer";
            show_in_menu_bar = true;
            smooth_scroll = false;
            thumbwheel_sensitivity = 14;
            ui_scale = "normal";
            update_prompt_seen = true;
            vertical_scroll_sensitivity = 14;
          };

          devices = {
            "serial:2312ap01jmr8" = {
              dpi = 1300;
              invert_scroll = true;
              smartshift = {
                auto_disengage = 10;
                mode = "ratchet";
                tunable_torque = 0;
              };

              # What the GUI caches on discovery. It only saves when this
              # differs, so declaring it verbatim keeps it from hitting the
              # read-only file. A device or transport not listed here (e.g.
              # the mouse over a receiver) will still try, and show the error.
              identity = {
                inherit capabilities;
                codename = "MX Master 3S";
                display_name = "MX Master 3S";
                kind = "mouse";
                model_info = {
                  entity_count = 3;
                  extended_model_id = 0;
                  model_ids = [
                    45108
                    0
                    0
                  ];
                  transports = {
                    bluetooth = false;
                    btle = true;
                    equad = false;
                    usb = false;
                  };
                  unit_id = [
                    0
                    0
                    0
                    0
                  ];
                };
              };
              links."direct:046d:b034" = { inherit capabilities; };
            };

            "camera:046d:094d:serial:2616apahp0q8" = {
              camera_profile = "default";
              camera_controls = {
                brightness = 128;
                contrast = 128;
                exposure = 156;
                exposure_auto = 1;
                low_light_compensation = 0;
                power_line_frequency = 2;
                saturation = 128;
                sharpness = 128;
                white_balance = 4000;
                white_balance_auto = 1;
              };
            };
          };
        };
      in
      {
        xdg.configFile."openlogi/config.toml" = {
          source = (pkgs.formats.toml { }).generate "openlogi-config.toml" settings;
          force = true;
        };
      };
  };
}
