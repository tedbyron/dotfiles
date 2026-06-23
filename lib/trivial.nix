{ pkgs, ... }:
let
  numeric = f: n: (builtins.fromTOML "parsed = ${f}${n}").parsed;
in
{
  configPath = path: ../config/${path};
  readConfig = path: builtins.readFile ../config/${path};

  # FIX: error: Cannot build '/nix/store/g5rds7zml517dwj51dp58gxq6y0736i0-from-yaml.drv'.
  #      Reason: required system or feature not available
  #      Required system: 'x86_64-linux' with features {}
  #      Current system: 'aarch64-darwin' with features {apple-virt, benchmark, big-parallel, nixos-test}

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
