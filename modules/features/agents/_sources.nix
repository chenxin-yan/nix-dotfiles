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
    rev = "d164eec2abdeffe63b2f4cd9fa1426723910a3be";
    hash = "sha256-hGfJnlmgcyav15Q9t1vVgDAWXNbgsV0woizhsbxDaGs=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "ebd8654c2c627f721eb8f9c0d1bd4090a29f9e10";
    hash = "sha256-5m6JW3U6EMYUg4YVLh7nRRTWGY3shrFQ0wK0bediVFc=";
  };

  humanlayerSkills = pkgs.fetchFromGitHub {
    owner = "humanlayer";
    repo = "skills";
    rev = "4d69d20f6e9b57b4fcf0d501ccfb1be961f0f329";
    hash = "sha256-ZuDObFjOFAahsvrxqDbL9FHrMVWx6Lnh5dttdsW+czo=";
  };

  caldoSkills = pkgs.fetchFromGitHub {
    owner = "caldoai";
    repo = "skills";
    rev = "d5b68dace378219890d821adb3685538e2c69b04";
    hash = "sha256-VkGhevHArTXRUV87vR5stCIOb6hPqTRJFIOsvwB68Lg=";
  };
}
