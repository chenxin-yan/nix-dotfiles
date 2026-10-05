# Rift, a tiling window manager for macOS with a niri-style scrolling layout.
# The TOML config is linked from the checkout rather than copied into the
# store: Rift reloads it on save, so tweaks need no rebuild. Rift has no
# config check command; a bad edit shows up in /tmp/rift_<user>.err.log.
{ config, ... }:
{
  features.rift.includes = with config.features; [ paths ];

  features.rift.darwin =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      user = config.system.primaryUser;

      # Upstream's release build. nixpkgs' rift-wm is 0.5.5, before the 0.6
      # scrolling-layout fixes, and a source build needs a cargoHash that only
      # a Darwin builder can produce. Not seen by update-pins (fetchurl).
      rift = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
        pname = "rift";
        version = "0.6.7";
        src = pkgs.fetchurl {
          url = "https://github.com/acsandmann/rift/releases/download/v${finalAttrs.version}/rift-universal-macos-${finalAttrs.version}.tar.gz";
          hash = "sha256-i5Qlyy2PrXYxf1KCmCY9YJ2kcjMWLNd1aynfann6Nco=";
        };
        sourceRoot = ".";
        # Keep upstream's bytes, and so its code signature.
        dontFixup = true;
        installPhase = ''
          runHook preInstall
          install -Dm755 -t $out/bin rift rift-cli
          runHook postInstall
        '';
        meta = {
          description = "Tiling window manager for macOS";
          homepage = "https://github.com/acsandmann/rift";
          license = lib.licenses.asl20;
          platforms = lib.platforms.darwin;
          sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
          mainProgram = "rift";
        };
      });

      # Accessibility approval belongs to the binary that asks for it, and
      # Background Task Management approval to the agent's executable path;
      # both reset when that path moves. A store path moves whenever the
      # derivation's inputs do, so the agent runs a copy at a fixed path,
      # which changes only when the pinned release does. Unlike sketchybar's
      # wrapper, a script exec'ing the store binary would not keep the
      # Accessibility grant.
      stableRift = "/usr/local/libexec/nix-darwin/rift";
    in
    {
      # rift-cli for sketchybar and the shell.
      environment.systemPackages = [ rift ];

      # Before `userLaunchd` loads the agent (RunAtLoad), as for sketchybar.
      system.activationScripts.launchd.text = lib.mkAfter ''
        mkdir -p /usr/local/libexec/nix-darwin
        install -m0555 ${rift}/bin/rift ${stableRift}
      '';

      launchd.user.agents.rift = {
        # run_on_start and exec binds look up sketchybar, rift-cli, jq and sh here.
        path = [
          pkgs.jq
          config.environment.systemPath
        ];
        environment.RUST_LOG = "error,warn,info";
        serviceConfig = {
          ProgramArguments = [ stableRift ];
          RunAtLoad = true;
          # Upstream's agent (`rift service install`): restart after a crash,
          # but not after a clean exit.
          KeepAlive = {
            SuccessfulExit = false;
            Crashed = true;
          };
          ProcessType = "Interactive";
          StandardOutPath = "/tmp/rift_${user}.out.log";
          StandardErrorPath = "/tmp/rift_${user}.err.log";
        };
      };
    };

  features.rift.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      xdg.configFile."rift/config.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/features/desktop/rift/config.toml";
    };
}
