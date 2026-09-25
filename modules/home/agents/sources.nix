{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "33375500bcea98d610eb30ce10ac4e59b89c390d";
    hash = "sha256-xUs7UX8pOcZwR0okaSbI/f8EE5F4Zi/BUd+nIZNafPc=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "c55ee46073ed923f86ce59a5eb3b6d895095d1b7";
    hash = "sha256-L3CpIT2DeI+fUFl9fcygojtQo2DzEen69rMD1XqR1vM=";
  };

  pstack = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "157aae39a733135e93d8b5b19ff62c6a84b0ad56";
    hash = "sha256-zeDqjhLFSi/xTmRnp4DmsvZ2oiLMVeSQhKGhC+IUiS8=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "e3ba2aa6f1e6f0bc4d69eb09c9f0d0a93af56156";
    hash = "sha256-PES5XrSYx0VBXWVHEDRykGy0SAmJfV/luzy8Gfg0aAQ=";
  };

  humanlayerSkills = pkgs.fetchFromGitHub {
    owner = "humanlayer";
    repo = "skills";
    rev = "ca7c8088db69e315a8b2deea43820270457f8f3c";
    hash = "sha256-BX9k5S3hwgik7AKxssUVm7VQRTjgjXVVcE2Jph88tS0=";
  };
}
