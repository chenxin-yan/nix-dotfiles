{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "683bc88e56f3e09ba94f7055977f3d3aa499f202";
    hash = "sha256-APw+xMKqRvkLnuQxttiyyIeylrIMSxZovQnw3xEl1C4=";
  };

  vercelSkills = pkgs.fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-skills";
    rev = "063bee94c3f4df8453406c830b0a7df0f2860278";
    hash = "sha256-tTSJf53OQltUfxTH4hdqcnw5ywCjCZP8/JqQ593cyB8=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "b0618bc436ad893b3c5e84e55fba86586d34a404";
    hash = "sha256-1QwFBwG+gORvDvW4HM0LrZlHZKmKtWr7pUHU0MAXF2Y=";
  };

  pstack = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "3a604672c46cd8187d2b19980eae0a34f9f91138";
    hash = "sha256-eA5GF6CgHgGoX7H+AWSF5xnvHjB1NgBlODJKlvOs7/U=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "9cc65d03aa2da1db7121b912d03596409ee340b8";
    hash = "sha256-diYM3gqcEboVi7OQff/SvlE0TKAIPTJDIggX7rZWslY=";
  };

  humanlayerSkills = pkgs.fetchFromGitHub {
    owner = "humanlayer";
    repo = "skills";
    rev = "653b6411c1f70c275a18e37673b042ff99f67ceb";
    hash = "sha256-W3dFEdIi4sz4CAZvaj1xjtN7xTRebF/WHOTQYCIe2Xo=";
  };
}
