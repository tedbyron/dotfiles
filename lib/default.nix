{ inputs, nixpkgs, lib }:
let
  inherit (builtins) listToAttrs;
  inherit (lib) attrValues foldr makeExtensible nameValuePair;

  modules = [ ./system.nix ];

  ted = makeExtensible
    (final: listToAttrs (map
      (path: nameValuePair
        (baseNameOf (toString path))
        (import path {
          inherit final inputs nixpkgs lib;
        }))
      modules));
in
ted.extend (final: prev: foldr (a: b: a // b) { } (attrValues prev))
