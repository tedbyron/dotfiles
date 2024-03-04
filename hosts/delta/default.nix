_:
let
  name = "gamma";
  users = [ "ted" ];
in
{
  imports = map (name: ../../users/${name}) users;

  homebrew.casks = [ "linearmouse" ];
  system.stateVersion = 4;

  networking = {
    computerName = name;
    hostName = name;
  };
}
