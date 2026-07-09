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
    rev = "d574778f94cf620fcc8ce741584093bc650a61d3";
    hash = "sha256-XqF709Y9GMKINzZITlbCTyatG9AxRZh0qn2vcv1Z8yo=";
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
    rev = "523e9dc051a073a85592e74c1f292ac93e3633da";
    hash = "sha256-3CU7VOeiWWtJQLF69+d91SbiwtVMowHKNtPkxoeV3vo=";
  };
}
