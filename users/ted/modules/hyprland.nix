{
  unstable,
  darwin,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = !darwin;
    package = unstable.hyprland; # TODO: 25.05; conflicts with programs.hyprland.package
    # portalPackage = null; # TODO: 25.05; conflicts with programs.hyprland.portalPackage
    systemd.enable = false; # UWSM

    # TODO
    plugins = with unstable.hyprlandPlugins; [
      hypr-dynamic-cursors
      # hyprpaper
      # hyprspace
      hyprsplit
      # hyprsunset
    ];

    # https://wiki.hyprland.org/Configuring/Variables
    settings = {
      env = [
        "XCURSOR_SIZE,12"
        "HYPRCURSOR_SIZE,12"
        "GDK_BACKEND,wayland,x11,*"
        "SDL_VIDEODRIVER,wayland"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      ];

      monitor = [
        "DP-5, 2560x1440@120, 0x0,        auto, vrr, 1"
        "DP-4, 2560x1440@60,  auto-right, auto, vrr, 0"
        ",     preferred,     auto,       auto"
      ];

      "$terminal" = "ghostty -e 'tmux new -As0'";
      "$fileManager" = "nautilus";
      "$menu" = "wofi --show drun";

      exec-once = [
        "dbus-update-activation-environment --systemd --all"

        "[monitor DP-5] $terminal"
        "[monitor DP-4] firefox"
        # "nm-applet &"
        # "waybar & hyprpaper & firefox"
      ];

      windowrule = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];

      general = {
        gaps_out = 10;
        "col.active_border" = "rgb(d65d0e)";
        "col.inactive_border" = "rgb(3c3836)";
        snap.enabled = true; # ???
      };

      decoration = {
        rounding = 10;
        blur.enabled = false;
      };

      animations = {
        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear, 0, 0, 1, 1"
          "almostLinear, 0.5, 0.5, 0.75, 1.0"
          "quick, 0.15, 0, 0.1, 1"
        ];

        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      dwindle.preserve_split = true;

      master = {
        new_status = "master";
        orientation = "right";
      };

      input = {
        repeat_delay = 300;
        follow_mouse = 1;
        touchpad.tap-and-drag = false;
      };

      device = [
        {
          name = "razer-naga-pro";
          sensitivity = -0.333; # Default 1200dpi
        }
      ];

      gestures.workspace_swipe = true;

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        background_color = "rgb(282828)";
        middle_click_paste = false;
      };

      plugin = [
        { hyprsplit.num_workspaces = 10; }
        {
          dynamic-cursors = {
            mode = "stretch";

            shake = {
              speed = 0;
              timeout = 0;
            };
          };
        }
      ];

      bind = [
        "SUPER, `, exec, $terminal"
        "SUPER, ;, killactive,"
        "SUPER, M, exit,"
        "SUPER, E, exec, $fileManager"
        "SUPER, V, togglefloating,"
        "SUPER, R, exec, $menu"
        "SUPER, J, togglesplit, # dwindle"
        "SUPER, D, split:swapactiveworkspaces, current +1"
        "SUPER, G, split:grabroguewindows"

        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"

        "SUPER, 1, split:workspace, 1"
        "SUPER, 2, split:workspace, 2"
        "SUPER, 3, split:workspace, 3"
        "SUPER, 4, split:workspace, 4"
        "SUPER, 5, split:workspace, 5"
        "SUPER, 6, split:workspace, 6"
        "SUPER, 7, split:workspace, 7"
        "SUPER, 8, split:workspace, 8"
        "SUPER, 9, split:workspace, 9"
        "SUPER, 0, split:workspace, 10"

        "SUPER SHIFT, 1, split:movetoworkspacesilent, 1"
        "SUPER SHIFT, 2, split:movetoworkspacesilent, 2"
        "SUPER SHIFT, 3, split:movetoworkspacesilent, 3"
        "SUPER SHIFT, 4, split:movetoworkspacesilent, 4"
        "SUPER SHIFT, 5, split:movetoworkspacesilent, 5"
        "SUPER SHIFT, 6, split:movetoworkspacesilent, 6"
        "SUPER SHIFT, 7, split:movetoworkspacesilent, 7"
        "SUPER SHIFT, 8, split:movetoworkspacesilent, 8"
        "SUPER SHIFT, 9, split:movetoworkspacesilent, 9"
        "SUPER SHIFT, 0, split:movetoworkspacesilent, 10"

        "SUPER, S, togglespecialworkspace, magic"
        "SUPER SHIFT, S, movetoworkspace, special:magic"

        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      cursor = {
        no_hardware_cursors = 1;
        hide_on_touch = false;
      };

      ecosystem.no_donation_nag = true;
    };
  };
}
