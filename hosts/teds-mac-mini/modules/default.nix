{ lib, ... }:
{
  imports =
    lib.filesystem.listFilesRecursive ./.
    |> lib.filter (f: lib.hasSuffix ".nix" f && f != ./default.nix);
}
