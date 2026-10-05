{ pkgs }:

{
  anthropicSkills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "8a1541c4a3ffa5a20a5a91de0dcf3f0bab1d1ef4";
    hash = "sha256-PRBkTEGNwT73EFCvuTprzIBGiG+UGSYiaCkY7Ji13us=";
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
    rev = "24fe0ef7737efae15c87225755e9f6f5965e4888";
    hash = "sha256-/mAmj7QFdyOWhLmy3Rt2/Hfsh5qwirTRax7hmQffFdo=";
  };

  pstack = pkgs.fetchFromGitHub {
    owner = "backnotprop";
    repo = "pstack";
    rev = "124f622bcaeac490e7e9dac6af83f3ef9611d554";
    hash = "sha256-3FDNTW+TTNLRNSefaKa9mhvSq7mohYWMaagjqIbELUA=";
  };

  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "920575badb772ded8c16bcae7fd7b6ed6fb20c63";
    hash = "sha256-XLFGToUG+sTIaHCWGHWd08S9DF48wIp70ssndPOWufU=";
  };

  humanlayerSkills = pkgs.fetchFromGitHub {
    owner = "humanlayer";
    repo = "skills";
    rev = "ca7c8088db69e315a8b2deea43820270457f8f3c";
    hash = "sha256-BX9k5S3hwgik7AKxssUVm7VQRTjgjXVVcE2Jph88tS0=";
  };
}
