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
  fd
  ffmpeg
  hexyl
  hyperfine
  imagemagick
  lychee
  nil
  nixfmt
  rust-bin.nightly.latest.default
  obsidian
  ouch
  tokei
  wasm-pack
  unstable.elixir
  unstable.nodejs
] ++ lib.optionals isDarwin [ mas pinentry_mac ]
