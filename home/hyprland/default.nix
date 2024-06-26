{
  pkgs,
  lib,
  osConfig,
  config,
  ...
}:
lib.mkIf osConfig.programs.hyprland.enable {
  home.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "auto";

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = [ "--all" ];
    settings = {
      "$mod" = "SUPER";

      monitor = [
        "DP-2,1920x1080@144, 1920x0, 1"
        "HDMI-A-1,1920x1080@60, 0x0, 1"
      ];

      exec-once = [
        "${pkgs.swaynotificationcenter}/bin/swaync"
        "${pkgs.nextcloud-client}/bin/nextcloud --background"
        "${pkgs.kdeconnect}/bin/kdeconnect-indicator"
        "${pkgs.protonmail-bridge-gui}/bin/protonmail-bridge-gui --no-window"
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.keepassxc}/bin/keepassxc"
        "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store -max-items 10"
        (lib.mkIf config.services.hypridle.enable "${pkgs.hypridle}/bin/hypridle")
      ];

      general = {
        gaps_in = 3;
        gaps_out = 10;

        border_size = 2;

        # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        # Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false;

        # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false;

        layout = "dwindle";
      };

      input = {
        kb_options = "compose:caps";
      };

      decoration = {
        rounding = 10;

        # Change transparency of focused and unfocused windows
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";

        # https://wiki.hyprland.org/Configuring/Variables/#blur
        blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = 0.1696;
        };
      };
      windowrulev2 = [
        "float,initialClass:(com.nextcloud.desktopclient.nextcloud)"
        "float,initialClass:(org.keepassxc.KeePassXC)"
        "workspace 5,initialClass:(lollypop)"
      ];
      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations = {

        enabled = true;

        # Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      dwindle = {
        pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # You probably want this
      };

      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      #master = {
      #new_status = "master";
      #};

      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc = {
        force_default_wallpaper = -1; # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = false; # If true disables the random hyprland logo / anime girl background. :(
      };

      bindm = [ "$mod,mouse:272,movewindow" ];

      bind =
        [
          "$mod, D, exec, rofi -config ${config.home.homeDirectory}/.config/rofi/config.rasi -show combi -automatic-save-to-history"
          "$mod, E, exec, ${pkgs.gnome.nautilus}/bin/nautilus"
          "$mod, Return, exec, ${pkgs.alacritty}/bin/alacritty"
          #"$mod, S, exec, rofi -show clipboard -show-icons"
          "$mod SHIFT, Q, killactive,"
          "$mod SHIFT, P, exec, rofi -show p -modi p:rofi-power-menu"
          "$mod, P, exec, cliphist wipe & ${pkgs.hyprlock}/bin/hyprlock"
          "$mod SHIFT, C, exec, hyprctl reload"
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Example special workspace (scratchpad)
          "$mod, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"
          "$mod, X, fullscreen, 1"
          "$mod, F, fullscreen, 0"
          "$mod, N, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client -t"

        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (
            builtins.genList (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  builtins.toString (x + 1 - (c * 10));
              in
              [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            ) 10
          )
        );
    };
  };
}
