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
  unstable.vscode
] ++ lib.optionals isDarwin [
  pinentry_mac
  rectangle
]
