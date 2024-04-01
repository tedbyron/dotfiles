{ pkgs, unstable, lib, isDarwin }:
with pkgs; [
  b3sum
  delta
  fd
  ffmpeg
  hexyl
  hyperfine
  nil
  nixfmt
  obsidian
  imagemagick
  lychee
  tokei
  unstable.elixir
  unstable.nodejs
] ++ lib.optionals isDarwin [
  mas
  pinentry_mac
]
