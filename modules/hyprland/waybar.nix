{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    package = pkgs.waybar;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        modules-left = [
          "custom/launcher"
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = ["clock"];
        modules-right = [
          "custom/brightness"
          "network"
          "cpu"
          "memory"
          "temperature"
          "wireplumber"
          "tray"
        ];

        "custom/launcher" = {
          format = " ";
          on-click = "wofi --show drun";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
          sort-by-number = true;
          active-only = false;
          all-outputs = true;
        };

        "hyprland/window" = {
          max-length = 50;
          separate-outputs = true;
        };

        "clock" = {
          format = "{:%I:%M %p}";
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "cpu" = {
          interval = 1;
          format = "{icon} {usage}% ";
          format-icons = [" " "▂" "▃" "▄" "▅" "▆" "▇" "█"];
          tooltip = true;
        };

        "memory" = {
          format = "RAM: {}%";
          tooltip-format = "Memory: {used:0.1f}GB/{total:0.0f}GB";
          interval = 1;
        };

        "temperature" = {
          hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
          critical-threshold = 85;
          format = "{icon} {temperatureC}°C";
          format-icons = ["" "" "" "" ""];
          interval = 2;
          tooltip = true;
          tooltip-format = "CPU Temperature: {temperatureC}°C";
        };

        "network" = {
          interface = "enp*";
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = " {ipaddr}/{cidr}";
          tooltip-format = " {ifname} via {gwaddr}";
          format-linked = " {ifname} (No IP)";
          format-disconnected = "⚠ Disconnected";
          format-alt = " {bandwidthUpBits} |  {bandwidthDownBits}";
          interval = 1;
        };

        "wireplumber" = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "󰝟";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["󰕿" "󰖀" "󰕾"];
          };
          scroll-step = 5;
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          on-click-right = "pavucontrol";
          on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          max-volume = 150;
          tooltip = true;
        };

        "custom/brightness" = {
          exec = "${config.home.homeDirectory}/.config/home-manager/modules/hyprland/scripts/brightness.sh get | tail -n1";
          format = "󰃠 {}%";
          interval = 2;
          on-scroll-up = "${config.home.homeDirectory}/.config/home-manager/modules/hyprland/scripts/brightness.sh up";
          on-scroll-down = "${config.home.homeDirectory}/.config/home-manager/modules/hyprland/scripts/brightness.sh down";
        };

        "tray" = {
          icon-size = 21;
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: #0a0a14;
        color: #f0c674;
      }

      #workspaces {
        background: #1c1c28;
        margin: 2px 4px;
      }

      #workspaces button {
        padding: 0 5px;
        background: transparent;
        color: #f0c674;
      }

      #workspaces button.active {
        background: #1c1c28;
        color: #ff3c3c;
      }

      #workspaces button:hover {
        background: #384048;
        color: #ff3c3c;
      }

      #custom-launcher,
      #window,
      #clock,
      #cpu,
      #temperature,
      #memory,
      #network,
      #wireplumber,
      #custom-brightness,
      #tray {
        padding: 0 10px;
        margin: 2px 4px;
        color: #f0c674;
        background: #1c1c28;
      }

      #custom-launcher {
        color: #ff3c3c;
        background: #1c1c28;
      }

      #window {
        margin: 2px 4px;
      }

      #clock {
        color: #f0c674;
        background-color: #1c1c28;
      }

      #network {
        color: #00bfff;
      }

      #temperature {
        color: #ff3c3c;
        margin-left: 0;
        padding-left: 4px;
      }

      #temperature.critical {
        background-color: #ff3c3c;
        color: #0a0a14;
      }

      #wireplumber {
        color: #03fff7;
      }

      #custom-brightness {
        color: #ffcc00;
        font-weight: bold;
        min-width: 70px;
      }

      #cpu {
        color: #73c936;
      }

      #memory {
        color: #ff7f00;
      }

      #tray {
        background: #1c1c28;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #ff3c3c;
      }
    '';
  };

  # Add required packages for Waybar functionality
  home.packages = with pkgs; [
    wireplumber # For better audio control
    iw # For better network interface detection
    pavucontrol # GUI for audio control
    lm_sensors # For temperature monitoring
    gtk3 # For GTK3 support
    gtk4 # For GTK4 support
    ddcutil # For monitor brightness control
    libnotify # For notifications
    wob # For brightness slider
    # Dependencies for memory graph
    procps    # Provides free
    gawk      # For text processing in scripts
  ];

  # Add wob configuration file
  xdg.configFile."wob/wob.ini".text = ''
    timeout = 1000
    border_size = 1
    margin = 100
    border_color = ffcc00ff
    bar_color = ffcc00ff
    background_color = 1c1c28aa
    height = 32
  '';

  # Add wob socket and service
  systemd.user.sockets.wob = {
    Socket = {
      ListenFIFO = "%t/wob.sock";
      SocketMode = "0600";
    };
    Install = {
      WantedBy = ["sockets.target"];
    };
  };

  systemd.user.services.wob = {
    Unit = {
      Description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
      PartOf = ["graphical-session.target"];
      Requires = ["wob.socket"];
      After = ["graphical-session.target" "wob.socket"];
    };
    Service = {
      StandardInput = "socket";
      ExecStart = "${pkgs.wob}/bin/wob";
      Environment = [
        "WAYLAND_DISPLAY=wayland-1"
        "XDG_RUNTIME_DIR=/run/user/1000"
      ];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  # Set environment variable for wob socket
  home.sessionVariables = {
    WOBSOCK = "$XDG_RUNTIME_DIR/wob.sock";
  };
} 