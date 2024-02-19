{ self, inputs, nixpkgs, lib }:
let
  modules = [ ./system.nix ];

  ted = lib.makeExtensible (final: builtins.listToAttrs (map
    (path: lib.nameValuePair
      (baseNameOf (toString path))
      (import path {
        inherit self final inputs nixpkgs lib;
      }))
    modules));
in
ted.extend (final: prev: lib.foldr (a: b: a // b) { } (lib.attrValues prev))
