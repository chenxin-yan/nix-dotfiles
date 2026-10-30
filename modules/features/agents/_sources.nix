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
    rev = "a496f5513d4a4cf889bc48e189e579f4b0bdf6aa";
    hash = "sha256-XpP8D7V2seR0sJ9bErscXgVLY2+6QiaA8TR/l8v2gx0=";
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
    rev = "653b6411c1f70c275a18e37673b042ff99f67ceb";
    hash = "sha256-W3dFEdIi4sz4CAZvaj1xjtN7xTRebF/WHOTQYCIe2Xo=";
  };
}
