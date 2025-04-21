{
  pkgs,
  unstable,
  darwin,
}:
{
  enable = !darwin;
  extraConfig = builtins.readFile ./hyprland.conf;
  package = unstable.hyprland;

  # TODO: hyprlock
  plugins = with pkgs.hyprlandPlugins; [
    # hypr-dynamic-cursors
    # hyprspace
    # hyprsplit
  ];

  settings = {

  };

  systemd = {
    enable = true;
    enableXdgAutostart = true;
  };
}
