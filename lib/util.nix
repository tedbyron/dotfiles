{ lib, ... }:
{
  nixFilesIn = dir: builtins.mapAttrs
    (name: _: import (dir + "/${name}"))
    (lib.filterAttrs
      (name: _: lib.hasSuffix ".nix" name)
      (builtins.readDir dir));
}
