{ pkgs, unstable, lib, isDarwin }:
with pkgs;
[
  b3sum
  cargo-binutils
  cargo-edit
  cargo-expand
  cargo-generate
  cargo-watch
  delta
  unstable.elixir
  fd
  ffmpeg
  hexyl
  hyperfine
  imagemagick
  lychee
  nil
  nixfmt
  unstable.nodejs
  obsidian
  openssl
  ouch
  tokei
  wasm-pack
] ++ lib.optionals isDarwin [ mas pinentry_mac ]
