{ pkgs, ... }:
let
  name = "gamma";
  user =  "ted";
in
{
  imports = [ ../../users/${user} ];

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
