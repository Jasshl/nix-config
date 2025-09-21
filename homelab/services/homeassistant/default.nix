{ config, lib, ... }:
let
  homelab = config.homelab;
  cfg = config.homelab.services.homeassistant;
in
{
  options.homelab.services.homeassistant = {
    enable = lib.mkEnableOption {
      description = "Enable Home Assistant";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/persist/opt/services/homeassistant";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "home.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Home Assistant";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Home automation platform";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "home-assistant.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Smart Home";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [ "d ${cfg.configDir} 0775 ${homelab.user} ${homelab.group} - -" ];
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://192.168.100.100:8123
      '';
    };
    virtualisation = {
      podman.enable = true;
      oci-containers = {
        containers = {
          homeassistant = {
            image = "homeassistant/home-assistant:stable";
            autoStart = true;
            extraOptions = [
              "--pull=newer"
              #"--network=host"      # <-- added for BLE & mDNS
              "--privileged"        # <-- added for /dev/hci access & D-Bus
            ];
            volumes = [
              "${cfg.configDir}:/config"
              "/run/dbus:/run/dbus:ro"           # <-- added to mount host D-Bus
              "/etc/localtime:/etc/localtime:ro" # <-- added for timezone
              "/etc/machine-id:/etc/machine-id:ro" # <-- added for container identity
            ];
            ports = [
              "8123:8123"
              "8124:80"
            ];
            environment = {
              TZ = homelab.timeZone;
              PUID = toString config.users.users.${homelab.user}.uid;
              PGID = toString config.users.groups.${homelab.group}.gid;
              DBUS_SYSTEM_BUS_ADDRESS = "unix:path=/run/dbus/system_bus_socket";
            };
          };
        };
      };
    };
  };
}
