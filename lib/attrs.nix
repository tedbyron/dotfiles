{ lib, ... }:
let
  inherit (lib) filterAttrs mapAttrs';
in
{
  # mapFilterAttrs ::
  #   (String -> Any -> Bool) ->
  #   (String -> Any -> { name = String; value = Any; }) ->
  #   AttrSet
  mapFilterAttrs = pred: f: attrs:
    filterAttrs pred (mapAttrs' f attrs);
}
