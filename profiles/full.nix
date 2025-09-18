{ ... }:

{
  imports = [
    ../modules/shared/core

    ../modules/shared/cli/opencode
    ../modules/shared/cli/codex
    ../modules/shared/cli/podman
    ../modules/shared/cli/yazi
    ../modules/shared/cli/zellij

    ../modules/shared/dev/lua
    ../modules/shared/dev/markdown
    ../modules/shared/dev/nix
    ../modules/shared/dev/python
    ../modules/shared/dev/typescript
    ../modules/shared/dev/web
    ../modules/shared/dev/bash
    ../modules/shared/dev/java
    ../modules/shared/dev/go

    ../modules/shared/app/ghostty
  ];
}
