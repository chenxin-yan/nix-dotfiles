{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dev.lua.enable = lib.mkEnableOption "enables Lua development tools";
  };

  config = lib.mkIf config.dev.lua.enable {
    home.packages = with pkgs; [
      lua51Packages.lua
      lua51Packages.luarocks
      lua-language-server
      stylua
    ];
  };
}
