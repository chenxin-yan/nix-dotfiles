# Linux file viewers, the tiling-WM community's usual picks: keyboard-driven,
# and themed by catppuccin/nix (theme.nix auto-enables it for each program).
# The Macs have Preview and IINA (mpv underneath).
{
  features.viewers.homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      programs.mpv.enable = true;
      programs.imv.enable = true;
      programs.zathura.enable = true;

      # Helium also claims images and PDFs, so the defaults are explicit.
      xdg.mimeApps = {
        enable = true;
        defaultApplications =
          lib.genAttrs [
            "video/mp4"
            "video/x-matroska"
            "video/webm"
            "video/quicktime"
            "video/x-msvideo"
            "video/mpeg"
            "video/ogg"
            "video/x-m4v"
            "audio/mpeg"
            "audio/flac"
            "audio/ogg"
            "audio/opus"
            "audio/x-wav"
            "audio/mp4"
            "audio/aac"
          ] (_: "mpv.desktop")
          # imv-dir: arrow keys step through the rest of the folder.
          // lib.genAttrs [
            "image/png"
            "image/jpeg"
            "image/gif"
            "image/webp"
            "image/bmp"
            "image/tiff"
            "image/svg+xml"
            "image/heif"
            "image/avif"
            "image/jxl"
          ] (_: "imv-dir.desktop")
          // lib.genAttrs [
            "application/pdf"
            "application/epub+zip"
          ] (_: "org.pwmt.zathura-pdf-mupdf.desktop");
      };
    };
}
