_:
let
  name = "gamma";
  users = [ "ted" ];
in
{
  imports = map (name: ../../users/${name}) users;

  system.stateVersion = 4;

  networking = {
    computerName = name;
    hostName = name;
  };

  homebrew.casks = [ "linearmouse" ];
}
