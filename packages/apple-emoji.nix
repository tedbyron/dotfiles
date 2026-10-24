# Upstream's flake now needs the TTC from macOS, so use its prebuilt release.
{ fetchurl, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "apple-emoji";
  version = "macos-26-20260722-484daf4e";

  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/${version}/AppleColorEmoji-Linux.ttf";
    hash = "sha256-43x69iZaxKCvbVe8ZehhCad22ZZug0MzRVf2PaSCUW8=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 $src $out/share/fonts/truetype/AppleColorEmoji.ttf
    runHook postInstall
  '';
}
