{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "ca45fc496a3436251f191354091d557da31c15b5";
    hash = "sha256-MkCOANBAqCc1WmNf7S8PsyAphGJAIzEXGyCm8RrCR9M=";
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
    rev = "25abb38559ddbabec563646224d09eff9a250eca";
    hash = "sha256-C4pCSuEBG5DAAdfpbz7EsYy/Yh4Hbl1Db4u4yPm4y2w=";
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
    rev = "69d5fc61d6ca6f7056d283a2ee2a045be741a1d6";
    hash = "sha256-I/FEGMmJvmkxAzdHEBnacrG5TcP4Y46Kk9lqkKE834M=";
  };
}
