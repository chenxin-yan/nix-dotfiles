# Where the dotfiles checkout and personal directories live. Features that
# read these options include this feature.
{
  features.paths.homeManager =
    { config, lib, ... }:
    {
      options = {
        dotfiles = lib.mkOption {
          type = lib.types.path;
          apply = toString;
          default = "${config.home.homeDirectory}/dotfiles";
          example = "${config.home.homeDirectory}/dotfiles";
          description = "Location of the dotfiles working copy";
        };
        devPath = lib.mkOption {
          type = lib.types.path;
          apply = toString;
          default = "${config.home.homeDirectory}/dev";
          description = "Location of development repositories";
        };
        atlasPath = lib.mkOption {
          type = lib.types.path;
          apply = toString;
          default = "${config.home.homeDirectory}/atlas";
          description = "Location of the Atlas Obsidian vault";
        };
      };

      config.home.sessionVariables = {
        XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
        DOTFILES_PATH = config.dotfiles;
        DEV_PATH = config.devPath;
        ATLAS_PATH = config.atlasPath;
      };
    };
}
