{
  self,
  inputs,
  lib,
}:
let
  modules = [ ./system.nix ];

  ted = lib.makeExtensible (
    _:
    builtins.listToAttrs (
      map (
        path:
        lib.nameValuePair (baseNameOf (toString path)) (
          import path {
            inherit self inputs lib;
          }
        )
      ) modules
    )
  );
in
ted.extend (_: prev: lib.foldr (a: b: a // b) { } (lib.attrValues prev))
