{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "1780c5e5a552fd4d1c9d6a7b0cab26b0c2bef064";
    hash = "sha256-pEKTL8YlOAem5QfNzLkjJaEDTp7PhtG/uyzjPzOL7Jo=";
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
    rev = "5863806dd4e15c63174bee4e7515a4256792ecfa";
    hash = "sha256-AYSRCvBL8TDDdW3rgKu2T7gl4YYDoDId0jYbabEFyfs=";
  };

  pstack = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "74bcc61bd216687b1d6d480c28f109adfc9824ec";
    hash = "sha256-pKlTrJYJ2p4Gg3U7CgPQyMjUOPeoosql0lG4MzO8FmQ=";
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
