# Feature registry and per-host selection. A feature is on for a host when
# the host selects it, directly or through another feature's `includes`;
# there are no enable flags. Each feature carries its half for every class
# it touches, so one name brings, say, kanata's darwin daemon and its Home
# Manager keymap together. Profiles are features too: config plus includes.
#
# Features are selected by reference (`with config.features; [ kanata ]`),
# so a misspelt name is an "attribute missing" error, not a silent no-op.
{ lib, ... }:
let
  featureRef =
    lib.types.addCheck lib.types.raw (f: builtins.isAttrs f && f ? name && f ? includes)
    // {
      name = "feature";
      description = "feature (config.features.<name>)";
    };

  classModule =
    class:
    lib.mkOption {
      # _class makes, say, a darwin half imported into NixOS an error.
      type = lib.types.deferredModuleWith { staticModules = [ { _class = class; } ]; };
      default = { };
      description = "The feature's ${class} module.";
    };

  # Breadth-first closure over `includes`, deduplicated by name (so cycles
  # terminate). Excluded features are dropped before their includes are
  # followed: excluding a profile drops everything only it brings.
  resolve =
    { features, exclude }:
    let
      excluded = map (f: f.name) exclude;
      keep = lib.filter (f: !lib.elem f.name excluded);
      node = f: {
        key = f.name;
        feature = f;
      };
    in
    map (n: n.feature) (
      builtins.genericClosure {
        startSet = map node (keep features);
        operator = n: map node (keep n.feature.includes);
      }
    );
in
{
  options.features = lib.mkOption {
    default = { };
    description = "Features hosts can select.";
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              default = name;
              readOnly = true;
              internal = true;
            };
            includes = lib.mkOption {
              type = lib.types.listOf featureRef;
              default = [ ];
              description = "Features selected along with this one.";
            };
            darwin = classModule "darwin";
            nixos = classModule "nixos";
            homeManager = classModule "homeManager";
          };
        }
      )
    );
  };

  options.hosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { config, ... }:
        {
          options = {
            features = lib.mkOption {
              type = lib.types.listOf featureRef;
              default = [ ];
              description = "Features this host selects.";
            };
            exclude = lib.mkOption {
              type = lib.types.listOf featureRef;
              default = [ ];
              description = "Exceptions: features never selected, even when included.";
            };
            selected = lib.mkOption {
              type = lib.types.listOf featureRef;
              readOnly = true;
              default = resolve { inherit (config) features exclude; };
              description = "The resolved feature set.";
            };
          };
        }
      )
    );
  };

  config.perSystem =
    { pkgs, ... }:
    {
      checks.feature-resolver =
        let
          f = name: includes: { inherit name includes; };
          c = f "c" [ ];
          b = f "b" [
            c
            a
          ];
          a = f "a" [
            b
            c
          ];
          d = f "d" [ ];
          names = host: map (x: x.name) (resolve host);
        in
        assert
          names {
            features = [
              a
              d
            ];
            exclude = [ ];
          } == [
            "a"
            "d"
            "b"
            "c"
          ];
        # c is excluded even though both a and b include it.
        assert
          names {
            features = [
              a
              d
            ];
            exclude = [ c ];
          } == [
            "a"
            "d"
            "b"
          ];
        # Excluding a profile drops what only it brings.
        assert
          names {
            features = [ a ];
            exclude = [ a ];
          } == [ ];
        pkgs.runCommandLocal "feature-resolver" { } "touch $out";
    };
}
