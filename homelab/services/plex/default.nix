# This is your new plex.nix file
{ config, lib, ... }:
let
  # 1. THE EASY CHANGE: Update the service name
  service = "plex";
  cfg = config.homelab.services.${service};
  homelab = config.homelab;
in
{
  # 2. UPDATE YOUR CUSTOM OPTIONS: Change the defaults to be Plex-specific
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption {
      description = "Enable ${service}";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/persist/opt/services/${service}";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "${service}.${homelab.baseDomain}";
    };
    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Plex"; # Changed
    };
    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Media Server"; # Changed
    };
    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "plex.svg"; # Changed
    };
    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Media"; # Changed
    };
  };

  config = lib.mkIf cfg.enable {
    # This block configures the Plex service itself. No changes needed here.
    services.${service} = {
      enable = true;
      dataDir = cfg.dataDir;
      user = homelab.user;
      group = homelab.group;
      openFirewall = true;
    };

    # This block configures Caddy. No changes needed here.
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:32400
      '';
    };

    # === COPY AND PASTE THIS BLOCK ===
    # This modifies the systemd sandbox rules for the Plex service.
    # It keeps the strong security of 'ProtectSystem=true' but adds an
    # explicit exception, allowing Plex to read and write to your media folder.
    systemd.services.plex = {
      serviceConfig = {
        ReadWritePaths = [ "/mnt/Exos1" ]; # <-- !!! REPLACE THIS PATH !!!
      };
    };
  };
}