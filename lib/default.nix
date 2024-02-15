{ inputs, nixpkgs, lib, ... }:
let
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  modules = import ./modules.nix {
    inherit lib;
    final.attrs = import ./attrs.nix {
      inherit lib;
      final = { };
    };
  };

  my = makeExtensible (final:
    mapModules ./. (file: import file { inherit final inputs nixpkgs lib; }));
in
my.extend (final: prev: foldr (a: b: a // b) { } (attrValues prev))
