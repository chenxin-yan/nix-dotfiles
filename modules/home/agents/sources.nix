{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "34040c9c568585f6929bedeaad110ad08f079624";
    hash = "sha256-tI4bTTBfI1ylltklGyiyA7pLoKXEWtrT6lrmwrpLbCw=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "3cca18b368ae95cdbdebbff572ccafa662551015";
    hash = "sha256-dF5i37jHnqfcXD1IRSVzSSm/pfCYSUmOsEhhs5Zx340=";
  };

  pstack = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "18e0e908a13553b0e58d065ab26dbc9a972ec8ba";
    hash = "sha256-NRg2kDFSV1O6v9YgHkYx2Yv8dZDs7pdQXPuyqXaGSNo=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "356918eba965ee1eac64bd3a7f0dd02108350de5";
    hash = "sha256-LPNMyHsri3+eeDmphEAKL1JgoRE4dLIPfZ4XZ+xu5UY=";
  };

  humanlayerSkills = pkgs.fetchFromGitHub {
    owner = "humanlayer";
    repo = "skills";
    rev = "3c2629142c5d437428269b1b722b08c0b87f574d";
    hash = "sha256-lJvu9CGAN/+dzmzck0CodRXn/p7GUkCbfyZxys4nIoU=";
  };
}
