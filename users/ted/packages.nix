{ pkgs, unstable, lib, isDarwin }:
with pkgs; [
  b3sum
  delta
  du-dust
  elixir
  fd
  ffmpeg
  hexyl
  hyperfine
  nil
  nixpkgs-fmt
  obsidian
  imagemagick
  lychee
  tokei
  unstable.nodejs
] ++ lib.optionals isDarwin [
  mas
  pinentry_mac
]
