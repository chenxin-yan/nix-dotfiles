{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "2c5958ecac7cee2b583967a2c4981d0f4a75c579";
    hash = "sha256-dRCZrNarCCJFuvATgfW6qmwwVS5HGFXNVGOhbVZd7LA=";
  };

  vercelSkills = pkgs.fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-skills";
    rev = "1a2c79d4e6c4a2283dc2c614b6538cbe1ed5ca62";
    hash = "sha256-uujS8sGulF6STR4adqYCHBxPY9pHddXfFfX6UqAG24c=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "4ae2317ddb22b046e26455e4f9c9b3aaaf62212d";
    hash = "sha256-3vhd77xfZjKUYJsIwPFevIZPUAzUgZXr0RYj5NQrBwk=";
  };

  pstack = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "a6342ded43a2437e3c664b46c2cff103787773fd";
    hash = "sha256-/zYoEU1nxKmG2mWcuxvkM7z6krZYs/3YZ1QjhOP7LN4=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "96608e078b2d5ea607c5c3b8b5a54d1c1fba6846";
    hash = "sha256-PhPtZbeX2wBp19GtWRy+fV93+fFYZe5S487eXPDl/us=";
  };

  humanlayerSkills = pkgs.fetchFromGitHub {
    owner = "humanlayer";
    repo = "skills";
    rev = "4d69d20f6e9b57b4fcf0d501ccfb1be961f0f329";
    hash = "sha256-ZuDObFjOFAahsvrxqDbL9FHrMVWx6Lnh5dttdsW+czo=";
  };
}
