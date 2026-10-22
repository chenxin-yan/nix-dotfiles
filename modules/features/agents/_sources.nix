{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "dbd4588f9e1033efb41dad4bef2f7947c8993d44";
    hash = "sha256-+UIqBnzyeIOvJSKYaDaE3GYPEpLw7qQqyUw5S971AfU=";
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
    rev = "5beb35b040e3de97e54fa9e386d7e42d15c295c2";
    hash = "sha256-2FKfe3/Fwc4MmwBLa+d/oQW4/gtYIssdWapy2MPd39I=";
  };

  pstack = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "e44668c2aad92eacf4e84df47984121fefb11b82";
    hash = "sha256-D2MTX3kirzLjS5hz46iyjBW2lUh9w5AUy9H2arIJy6U=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "09c434ab73ca43761c5d8b0c5d341926c2fba710";
    hash = "sha256-sVnxA4rfxa2SlS2g+2+q3odRq0VJz1z7PEVHW2QRPQI=";
  };

  humanlayerSkills = pkgs.fetchFromGitHub {
    owner = "humanlayer";
    repo = "skills";
    rev = "653b6411c1f70c275a18e37673b042ff99f67ceb";
    hash = "sha256-W3dFEdIi4sz4CAZvaj1xjtN7xTRebF/WHOTQYCIe2Xo=";
  };
}
