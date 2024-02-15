{ inputs, nixpkgs, overlays, lib }:
let
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  modules = import ./modules.nix {
    inherit lib;
    self.attrs = import ./attrs.nix {
      inherit lib;
      self = {};
    };
  };

  my = makeExtensible (self:
    with self;
    mapModules ./. (file: import file {
      inherit self inputs nixpkgs lib;
    }));
in
my.extend (self: super:
  foldr (a: b: a // b) {} (attrValues super))
