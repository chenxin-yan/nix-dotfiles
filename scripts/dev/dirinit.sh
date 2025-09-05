#!/usr/bin/env bash

set -euo pipefail

# Check if flake.nix already exists
if [[ -f "flake.nix" ]]; then
    echo "flake.nix already exists in current directory"
    exit 1
fi

# Create flake.nix with development environment boilerplate
cat > flake.nix << 'EOF'
{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
          ];

          shellHook = ''
          '';
        };
      }
    );
}
EOF

# Create .envrc with "use flake"
echo "use flake" > .envrc

# Add .direnv to .gitignore if not present
if [[ -f ".gitignore" ]]; then
    if ! grep -q "^\.direnv$" .gitignore; then
        echo ".direnv" >> .gitignore
        echo "📝 Added .direnv to .gitignore"
    fi
    if ! grep -q "^!\.envrc$" .gitignore; then
        echo "!.envrc" >> .gitignore
        echo "📝 Added !.envrc to .gitignore"
    fi
elif [[ -d ".git" ]]; then
    cat > .gitignore << 'EOF'
.direnv
!.envrc
EOF
    echo "📝 Created .gitignore with .direnv and !.envrc"
fi

# Stage all files for git if in a git repository
if [[ -d ".git" ]]; then
    git add .
    echo "📦 Staged all files with git add ."
fi

# Run direnv allow
direnv allow

echo "✅ Initialized flake.nix project with direnv integration"
echo "📁 Created: flake.nix, .envrc"
echo "🔧 Ran: direnv allow"
