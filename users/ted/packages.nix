{ pkgs, isDarwin }:
with pkgs; [
  delta
  du-dust
  ffmpeg
  hexyl
  hyperfine
  imagemagick
  lychee
  obsidian
  spotify
  tokei
] ++ lib.optionals isDarwin [
  pinentry_mac
  rectangle
]
