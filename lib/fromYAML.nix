{ pkgs, ... }:
{
  fromYAML =
    s:
    let
      jsonOutputDrv = pkgs.runCommandLocal "from-yaml" {
        nativeBuildInputs = [ pkgs.yq-go ];
      } "yq -o json - <<<'${s}' > $out";
    in
    builtins.fromJSON (builtins.readFile jsonOutputDrv);
}
