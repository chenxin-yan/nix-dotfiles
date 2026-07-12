{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "9d2f1ae187231d8199c64b5b762e1bdf2244733d";
    hash = "sha256-U7Nt1xrFOSOEm4vuWmy4pVsEyvv+Hj4sv8yXOofmwAw=";
  };

  mattpocockSkills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "391a2701dd948f94f56a39f7533f8eea9a859c87";
    hash = "sha256-gFPkjrujFAoNXYa0ariPKTj/xBoiCTLUo3X20qrTzRE=";
  };

  raindropSkills = pkgs.fetchFromGitHub {
    owner = "raindrop-ai";
    repo = "skills";
    rev = "7d80323c7ae0938fa6eb0c0c88f819a4da6e6ed8";
    hash = "sha256-eJ4lVBhdoRblii7B/O4SqomvPAgqCmMJHinnxOooHVU=";
  };

  raindropWorkshop = pkgs.fetchFromGitHub {
    owner = "raindrop-ai";
    repo = "workshop";
    rev = "914d74dc2c5dbfc13fa19ab9eb9bae0ecd48939e";
    hash = "sha256-7X41HYzcGpe/Z9l80ZrwYIJAaaYaig1Jf4Pj5xmbj+M=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "14a0d79548d4de8fc2de95c1b94bb0de63a739d3";
    hash = "sha256-aspTFUIRsyR2yiy3jqVsvwC/xiposWdM9j3DrVX06M8=";
  };
}
