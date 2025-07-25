{ config, lib, ... }:
let
  service = "jellyseerr";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/persist/opt/services/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5055;
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Jellyseerr";
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Media request and discovery manager";
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "jellyseerr.svg";
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Arr";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      port = cfg.port;
      configDir = cfg.configDir;
    };
    systemd = {
      tmpfiles.rules = [
        "d ${cfg.configDir} 0777 ${homelab.user} ${homelab.group} -"
      ];
      services.${service}.serviceConfig.ReadWritePaths = [ cfg.configDir ];
    };
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    };
  };

}
