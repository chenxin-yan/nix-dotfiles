{ config, lib, ... }:
let
  inherit (config) features;

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
              # The platform profile follows `system`, so it cannot be
              # forgotten or disagree with it.
              default = resolve {
                features = [
                  (if lib.hasSuffix "-darwin" config.system then features.darwin else features.nixos)
                ]
                ++ config.features;
                inherit (config) exclude;
              };
              description = "The resolved feature set, platform profile first.";
            };
          };
        }
      )
    );
  };

}
