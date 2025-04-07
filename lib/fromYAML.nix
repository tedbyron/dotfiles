{ pkgs, ... }:
{
  fromYAML =
    e:
    let
      jsonOutputDrv = pkgs.runCommandLocal "from-yaml" {
        nativeBuildInputs = with pkgs; [ yq-go ];
      } "yq -o json - <<<'${e}' > $out";
    in
    builtins.fromJSON (builtins.readFile jsonOutputDrv);
}
