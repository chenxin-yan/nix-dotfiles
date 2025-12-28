{ lib, config, ... }:

{
  imports = [
    ./bash
    ./go
    ./java
    ./latex
    ./lua
    ./markdown
    ./nix
    ./python
    ./typescript
    ./web
    ./c
    ./sql
  ];

  config = {
    dev.bash.enable = lib.mkDefault true;
    dev.go.enable = lib.mkDefault true;
    dev.java.enable = lib.mkDefault true;
    dev.latex.enable = lib.mkDefault true;
    dev.lua.enable = lib.mkDefault true;
    dev.markdown.enable = lib.mkDefault true;
    dev.nix.enable = lib.mkDefault true;
    dev.python.enable = lib.mkDefault true;
    dev.typescript.enable = lib.mkDefault true;
    dev.web.enable = lib.mkDefault true;
    dev.c.enable = lib.mkDefault true;
    dev.sql.enable = lib.mkDefault true;
  };
}
