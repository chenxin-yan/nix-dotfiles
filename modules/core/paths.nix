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
        projectsPath = lib.mkOption {
          type = lib.types.path;
          apply = toString;
          default = "${config.home.homeDirectory}/PARA/01 Projects";
          description = "Location of project directories";
        };
      };

      config.home.sessionVariables = {
        XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
        DOTFILES_PATH = config.dotfiles;
        DEV_PATH = config.devPath;
        PROJECTS_PATH = config.projectsPath;
        AREAS_PATH = "${config.home.homeDirectory}/PARA/02 Areas";
        NOTES_PATH = "${config.home.homeDirectory}/notes";
      };
    };
}
