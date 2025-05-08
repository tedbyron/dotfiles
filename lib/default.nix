{
  self,
  pkgs,
  unstable,
  lib,
}:
let
  modules = [
    ./mkSystem.nix
    ./trivial.nix
  ];

  ted = lib.makeExtensible (
    _:
    builtins.listToAttrs (
      map (
        path:
        lib.nameValuePair (builtins.baseNameOf (builtins.toString path)) (
          import path {
            inherit
              self
              pkgs
              unstable
              lib
              ;
          }
        )
      ) modules
    )
  );

in
ted.extend (_: prev: lib.foldr (a: b: a // b) { } (lib.attrValues prev))
