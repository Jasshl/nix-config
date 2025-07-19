{ config, lib, ... }:
let
  hl = config.homelab;
in
{
  homelab = {
    enable = true;
    baseDomain = "j.magicsk.eu";
    cloudflare.dnsCredentialsFile = config.age.secrets.cloudflareDnsApiCredentials.path;
    timeZone = "Europe/Bratislava";
    mounts = {
      config = "/persist/opt/services";
      Exos1_8tb = "/mnt/Exos1_8tb";
      GreenStorage = "/mnt/GreenStorage";
      BlueStorage = "/mnt/BlueStorage";
      Arch = "/mnt/Arch";
    };
    samba = {
      enable = true;
      passwordFile = config.age.secrets.sambaPassword.path;
      shares = {
        Exos1_8tb = {
          path = "${hl.mounts.Exos1_8tb}";
        };
        GreenStorage = {
          path = hl.mounts.GreenStorage;
        };
        BlueStorage = {
          path = hl.mounts.BlueStorage;
        };
        Arch = {
          path = hl.mounts.Arch;
        };
        config = {
          path = hl.mounts.config;
          "follow symlinks" = "yes";
          "wide links" = "yes";
        };
        # TimeMachine = {
        #   path = "${hl.mounts.Exos1_8tb}/TimeCapsule";
        #   "fruit:time machine" = "yes";
        # };
      };
    };
    services = {
      enable = true;
      immich = {
        enable = true;
        mediaDir = "${hl.mounts.GreenStorage}/Photos";
      };
      /* homepage = {
        enable = true;
        misc = [
          {
            PiKVM =
              let
                ip = config.homelab.networks.local.lan.reservations.pikvm.Address;
              in
              {
                href = "https://${ip}";
                siteMoGreenStorage = "https://${ip}";
                description = "Open-source KVM solution";
                icon = "pikvm.png";
              };
          }
          {
            FritzBox = {
              href = "http://192.168.178.1";
              siteMoGreenStorage = "http://192.168.178.1";
              description = "Cable Modem WebUI";
              icon = "avm-fritzbox.png";
            };
          }
          {
            "Immich (Parents)" = {
              href = "https://photos.aria.goose.party";
              description = "Self-hosted photo and video management solution";
              icon = "immich.svg";
              siteMoGreenStorage = "";
            };
          }
        ];
      }; */
      homeassistant.enable = true;
      jellyfin.enable = true;
      /* paperless = {
        enable = true;
        passwordFile = config.age.secrets.paperlessPassword.path;
      }; */
      sonarr.enable = true;
      radarr.enable = true;
      prowlarr.enable = true;
      jellyseerr.enable = true;
      nextcloud = {
        enable = true;
        adminpassFile = config.age.secrets.nextcloudAdminPassword.path;
      };
      vaultwarden.enable = true;
      /* audiobookshelf.enable = true; */
      # deluge.enable = true;
    };
  };
}
