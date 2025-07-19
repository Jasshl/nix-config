{ lib, config, ... }:
let
  cfg = config.homelab;
in
{
  options.homelab = {
    enable = lib.mkEnableOption "The homelab services and configuration variables";
    mounts.config = lib.mkOption {
      default = "/persist/opt/services";
      type = lib.types.path;
      description = ''
        Path to the service configuration files
      '';
    };
    mounts.Exos1_8tb = lib.mkOption {
      default = "/mnt/Exos1_8tb";
      type = lib.types.path;
      description = ''
        Path to the Exos1_8tb (HDD 8TB)
      '';
    };
    mounts.BlueStorage = lib.mkOption {
      default = "/mnt/BlueStorage";
      type = lib.types.path;
      description = ''
        Path to the BlueStorage (HDD 4TB)
      '';
    };
    mounts.GreenStorage = lib.mkOption {
      default = "/mnt/GreenStorage";
      type = lib.types.path;
      description = ''
        Path to the GreenStorage (HDD 2TB)
      '';
    };
    mounts.Arch = lib.mkOption {
      default = "/mnt/Arch";
      type = lib.types.path;
      description = ''
        Path to the Arch (SSD 512GB)
      '';
    };
    user = lib.mkOption {
      default = "jashi";
      type = lib.types.str;
      description = ''
        User to run the homelab services as
      '';
      #apply = old: builtins.toString config.users.users."${old}".uid;
    };
    group = lib.mkOption {
      default = "jashi";
      type = lib.types.str;
      description = ''
        Group to run the homelab services as
      '';
      #apply = old: builtins.toString config.users.groups."${old}".gid;
    };
    timeZone = lib.mkOption {
      default = "Europe/Bratislava";
      type = lib.types.str;
      description = ''
        Time zone to be used for the homelab services
      '';
    };
    baseDomain = lib.mkOption {
      default = "j.magicsk.eu";
      type = lib.types.str;
      description = ''
        Base domain name to be used to access the homelab services via Caddy reverse proxy
      '';
    };
    cloudflare.dnsCredentialsFile = lib.mkOption {
      type = lib.types.path;
    };
  };
  imports = [
    ./services
    ./samba
    /* ./networks */
    ./motd
  ];
}
