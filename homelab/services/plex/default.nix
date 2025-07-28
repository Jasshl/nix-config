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

  # 3. THE CRUCIAL PART: Map your options to the REAL NixOS Plex service
  config = lib.mkIf cfg.enable {
    # This block now configures services.plex.* instead of services.radarr.*
    services.${service} = {
      enable = true;
      dataDir = cfg.dataDir;
      user = homelab.user;
      group = homelab.group;
      # This option is specific to the Plex module and very useful!
      openFirewall = true;
    };

    # Update the reverse proxy to point to the correct Plex port (32400)
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:32400
      '';
    };
  };
}