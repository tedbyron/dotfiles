{ pkgs, lib, isDarwin }:
with pkgs; [
  delta
  du-dust
  elixir
  fd
  ffmpeg
  hexyl
  hyperfine
  nodejs
  nil
  nixpkgs-fmt
  imagemagick
  lychee
  tokei

  obsidian
] ++ lib.optionals isDarwin [
  pinentry_mac
  rectangle
]
