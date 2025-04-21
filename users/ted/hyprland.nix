{ pkgs, darwin }:
{
  enable = !darwin;

  extraConfig = builtins.readFile ./hyprland-example.conf;

  # TODO: hyprlock
  plugins = with pkgs.hyprlandPlugins; [
    hypr-dynamic-cursors
    hyprspace
    hyprsplit
  ];

  settings = {

  };

  systemd = {
    enable = true;
    enableXdgAutostart = true;
  };
}
