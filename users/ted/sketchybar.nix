{ }:
{
  enable = true;

  config = ''
    PLUGIN_DIR="''$CONFIG_DIR/plugins"

    sketchybar --bar position=top height=40 blur_radius=30 color=0xff282828

    default=(
      padding_left=5
      padding_right=5
      icon.font="Curlio:Bold:17.0"
      label.font="Curlio:Bold:14.0"
      icon.color=0xffebdbb2
      label.color=0xffebdbb2
      icon.padding_left=4
      icon.padding_right=4
      label.padding_left=4
      label.padding_right=4
    )
    sketchybar --default "''${default[@]}"

    SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")
    for i in "''${!SPACE_ICONS[@]}"
    do
      sid="''$((''$i+1))"
      space=(
        space="''$sid"
        icon="''${SPACE_ICONS[i]}"
        icon.padding_left=7
        icon.padding_right=7
        background.color=0xff282828
        background.corner_radius=5
        background.height=25
        label.drawing=off
        script="''$PLUGIN_DIR/space.sh"
        click_script="yabai -m space --focus ''$sid"
      )
      sketchybar --add space space."''$sid" left --set space."''$sid" "''${space[@]}"
    done

    sketchybar --add item chevron left \
               --set chevron icon= label.drawing=off \
               --add item front_app left \
               --set front_app icon.drawing=off script="''$PLUGIN_DIR/front_app.sh" \
               --subscribe front_app front_app_switched

    sketchybar --add item clock right \
               --set clock update_freq=10 icon=  script="''$PLUGIN_DIR/clock.sh" \
               --add item volume right \
               --set volume script="''$PLUGIN_DIR/volume.sh" \
               --subscribe volume volume_change \
               --add item battery right \
               --set battery update_freq=120 script="''$PLUGIN_DIR/battery.sh" \
               --subscribe battery system_woke power_source_change

    sketchybar --update
  '';
}
