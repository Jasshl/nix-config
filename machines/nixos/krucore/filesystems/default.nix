{
  config,
  pkgs,
  ...
}:
let
  hl = config.homelab;
in
{

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true; # Optional: power on Bluetooth by default
  
  # Enable Bluetooth manager (blueman is popular)
  services.blueman.enable = false;
  services.dbus.enable = true;

  # Optional: install CLI tools like bluetoothctl
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
  ];

  # Make sure your user is in the necessary group
  users.users.jashi.extraGroups = [ "bluetooth" ];

  systemd.tmpfiles.rules = [
    "d /mnt/Exos1_8tb 0755 root root -"
    "d /mnt/BlueStorage 0755 root root -"
    "d /mnt/GreenStorage 0755 root root -"
    "d /mnt/Arch 0755 root root -"
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/eeb37e6a-245b-4b97-8d26-bab6f0d793e5";
      fsType = "btrfs";
      options = [ "subvol=@nix_root" "compress=zstd:2" ];
      neededForBoot = true;
    };
    
  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/eeb37e6a-245b-4b97-8d26-bab6f0d793e5";
      fsType = "btrfs";
      options = [ "subvol=nix" "compress=zstd:2" ];
      neededForBoot = true;
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/eeb37e6a-245b-4b97-8d26-bab6f0d793e5";
      fsType = "btrfs";
      options = [ "subvol=@nix_home" "compress=zstd:2" "noatime" "space_cache=v2" ];
      neededForBoot = true;
    };

  fileSystems."/mnt/Exos1_8tb" =
    { device = "/dev/disk/by-uuid/49b5f06b-e767-4f94-9a00-f50058dfcabc";
      fsType = "btrfs";
      options = [ "compress=zstd:3" "noatime" "space_cache=v2" ];
    };
    
  fileSystems."/mnt/GreenStorage" =
    { device = "/dev/disk/by-uuid/0f1c73dc-ba9e-4d92-a2cf-6b98b1ae8d51";
      fsType = "btrfs";
      options = [ "compress=zstd:2" "noatime" "space_cache=v2" ];
    };

  fileSystems."/mnt/BlueStorage" =
    { device = "/dev/disk/by-uuid/f2dd787a-8094-4165-805d-2ff6d157c044";
      fsType = "btrfs";
      options = [ "compress=zstd:2" "noatime" "space_cache=v2" ];
    };

  fileSystems."/mnt/Arch" =
    { device = "/dev/disk/by-uuid/eeb37e6a-245b-4b97-8d26-bab6f0d793e5";
      fsType = "btrfs";
      options = [ "compress=zstd:2" "noatime" "space_cache=v2" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/26EA-7756";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
      neededForBoot = true;
    };

  swapDevices = [{
      device = "/var/lib/swapfile";
      size = 16*1024; # 16 GB
    }];

    

  # services.smartd = {
  #   enable = true;
  #   defaults.autodetected = "-a -o on -S on -s (S/../.././02|L/../../6/03) -n standby,q";
  #   notifications = {
  #     wall = {
  #       enable = true;
  #     };
  #     mail = {
  #       enable = true;
  #       sender = config.email.fromAddress;
  #       recipient = config.email.toAddress;
  #     };
  #   };
  # };

}