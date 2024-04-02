{ pkgs, unstable, lib, isDarwin }:
with pkgs;
[
  b3sum
  delta
  fd
  ffmpeg
  hexyl
  hyperfine
  imagemagick
  lychee
  nil
  nixfmt
  obsidian
  tokei
  unstable.elixir
  unstable.nodejs
] ++ lib.optionals isDarwin [ mas pinentry_mac ]
