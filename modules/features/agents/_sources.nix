{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "e4bb5d960d87126ff3b3a8af1a104b7db67560ba";
    hash = "sha256-Gr9LatjawHHK9uKpoclWoiDHZ0NTpP3/4Pmeatl8p/Q=";
  };

  vercelSkills = pkgs.fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-skills";
    rev = "5a37a6329fbad3666c3207392a6a7c0110e92efb";
    hash = "sha256-gGacyJJnu1wf2y1CKGVjIyVbTOBnkly2ouYQSbgPb0E=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "abeeaf95660ba9e8b7c753eb38f441ca707a8823";
    hash = "sha256-fc5+qmchp1IQ/rQP1olWKC1eC4VdYhaB7YYzC3+JBe0=";
  };

  pstack = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "c3464c11c60b1352d5e8f5f0428a3a6943837568";
    hash = "sha256-SgUWRVdHeCqQ4mKHG8JcbHvYbM9GAcr32MvBtNc5zks=";
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
