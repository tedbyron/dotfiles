{
  pkgs,
  unstable,
  lib,
  darwin,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      wabt
      cargo-binutils
      cargo-edit
      cargo-expand
      cargo-features-manager
      cargo-generate
      cargo-pgo
      cargo-watch
      delta
      fd
      ffmpeg
      hexyl
      hyperfine
      imagemagickBig
      just
      lychee
      nil
      nixfmt-rfc-style
      unstable.nodejs
      ouch
      tokei
      wasm-pack
    ]
    ++ lib.optionals darwin [
      mas
      pinentry_mac
      vlc-bin
    ]
    ++ lib.optionals (!darwin) [
      gcr_4
      nautilus
      vlc
      wl-clipboard
      zig
    ];
}
