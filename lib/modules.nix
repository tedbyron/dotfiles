{ final, lib, ... }:
let
  inherit (builtins) readDir pathExists toString;
  inherit (lib) hasPrefix hasSuffix nameValuePair removeSuffix;
  inherit (final.attrs) mapFilterAttrs;
in
{
  # mapModules :: Path -> (String -> Any) -> AttrSet
  mapModules = dir: fn:
    mapFilterAttrs
      (n: v:
        v != null && !(hasPrefix "_" n))
      (n: v:
        let path = "${toString dir}/${n}"; in
        if v == "directory" && pathExists "${path}/default.nix"
        then nameValuePair n (fn path)
        else if v == "regular" &&
          n != "default.nix" &&
          hasSuffix ".nix" n
        then nameValuePair (removeSuffix ".nix" n) (fn path)
        else nameValuePair "" null)
      (readDir dir);
}
