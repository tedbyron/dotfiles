{ pkgs, ... }:
let
  numeric = f: n: (fromTOML "parsed = ${f}${n}").parsed;
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

  # launchd runs jobs at boot before the nix store volume is mounted, and gives
  # up on some after they fail to spawn; nix-darwin's `command` does the same
  waitForNix =
    args:
    [
      "/bin/sh"
      "-c"
      ''/bin/wait4path /nix/store && exec "$0" "$@"''
    ]
    ++ args;
}
