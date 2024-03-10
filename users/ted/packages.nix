{ pkgs, unstable, lib, isDarwin }:
with pkgs; [
  delta
  du-dust
  elixir
  fd
  ffmpeg
  hexyl
  hyperfine
  nil
  nixpkgs-fmt
  imagemagick
  lychee
  tokei
  unstable.nodejs

  obsidian
  unstable.vscode
] ++ lib.optionals isDarwin [
  pinentry_mac
  rectangle
]
