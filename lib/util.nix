{ pkgs, ... }:
let
  numeric = f: n: (builtins.fromTOML "parsed = ${f}${n}").parsed;
in
{
  configPath = path: ../config/${path};
  readConfig = path: builtins.readFile ../config/${path};

  fromYAML =
    s:
    "yq -o json - <<<'${s}' > $out"
    |> pkgs.runCommandLocal "from-yaml" { nativeBuildInputs = [ pkgs.yq-go ]; }
    |> builtins.readFile
    |> builtins.fromJSON;

  hex = n: numeric "0x" n;
  bin = n: numeric "0b" n;
  oct = n: numeric "0o" n;
}
