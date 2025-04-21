{
  pkgs,
  darwin,
}:
{
  enable = !darwin;
  extraConfig = builtins.readFile ./hyprland.conf;
  # package = null; # TODO: 25.05; conflicts with programs.hyprland.package
  # portalPackage = null; # TODO: 25.05; conflicts with programs.hyprland.portalPackage
  systemd.enable = false; # Conflicts with UWSM

  # TODO: hyprlock
  plugins = with pkgs.hyprlandPlugins; [
    # hypr-dynamic-cursors
    # hyprspace
    # hyprsplit
  ];

  settings = {

  };
}
