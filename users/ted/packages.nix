{ pkgs, isDarwin }:
{
  packages = with pkgs;[
    delta
    du-dust
    lychee
    obsidian
  ] ++ lib.optionals isDarwin [
    pinentry_mac
    rectangle
  ];
}
