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
    rev = "d81f3a183412e71a5b1e84ca21bc1a35eea03a60";
    hash = "sha256-zQ/wVrcHjIC+UjP4nDw3HARMqZd6LIDFmHKlp8AADYI=";
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
