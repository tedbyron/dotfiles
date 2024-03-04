{ pkgs, ... }:
let
  name = "gamma";
  users = [ "ted" ];
in
{
  imports = map (name: ../../users/${name}) users;

  system.stateVersion = 4;

  environment.systemPackages = with pkgs; [
    discord
    qbittorrent
  ];

  networking = {
    computerName = name;
    hostName = name;
  };
}
