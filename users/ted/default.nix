{ pkgs, isDarwin, ... }:
let
  name = "ted";
  home = if isDarwin then "/Users/${name}" else "/home/${name}";
in
{
  users.users.${name} = {
    inherit home;
    description = "Teddy Byron";
    shell = pkgs.zsh;
  };

  home-manager.users.${name} = {
    home = {
      stateVersion = "23.11";
      homeDirectory = home;
    };
  };
}
