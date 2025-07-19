{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  hl = config.homelab;
  hardDrives = [
    "/dev/disk/by-label/Data"
    "/dev/disk/by-label/Storage"
  ];
in
{
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        vaapiVdpau
        intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
        vpl-gpu-rt # QSV on 11th gen or newer
      ];
    };
  };

  programs.fuse.userAllowOther = true;
  
  boot = {
    kernelParams = [
      "pcie_aspm=force"
      "consoleblank=60"
      "acpi_enforce_resources=lax"
    ];
    kernelModules = [
      "kvm-intel"
      "coretemp"
      "jc42"
      "lm78"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  };

  networking = {
    # Use systemd-networkd for simple, reliable networking on servers.
    networkmanager.enable = false;
    
    # Set the name your server will have on the network.
    hostName = "krucore";
    
    # Tell your specific network interface to get an IP address via DHCP.
    # !!! IMPORTANT: Replace "eno1" with the name you found using `ip a` !!!
    interfaces.enp1s0.useDHCP = true;
    
    # It's highly recommended to enable the firewall on a server.
    firewall = {
      enable = false;
      
      # This will allow you to SSH into your server.
      allowedTCPPorts = [ 22 ];
      
      # Optional: Allow other devices on the network to ping your server.
      allowPing = true;
    };
  };


  imports = [
    ./homelab
    ./filesystems
    ./secrets
  ];

/*   systemd.services.hd-idle = {
    description = "External HD spin down daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart =
        let
          idleTime = toString 900;
          hardDriveParameter = lib.strings.concatMapStringsSep " " (x: "-a ${x} -i ${idleTime}") hardDrives;
        in
        "${pkgs.hd-idle}/bin/hd-idle -i 0 ${hardDriveParameter}";
    };
  }; */

/*   services.hddfancontrol = {
    enable = true;
    settings = {
      harddrives = {
        disks = hardDrives;
        pwmPaths = [ "/sys/class/hwmon/hwmon2/device/pwm2:50:50" ];
        extraArgs = [
          "-i 30sec"
        ];
      };
    };
  }; */

  virtualisation.docker.storageDriver = "overlay2";

  system.autoUpgrade.enable = true;

/*   services.mover = {
    enable = true;
    cacheArray = hl.mounts.fast;
    backingArray = hl.mounts.slow;
    user = hl.user;
    group = hl.group;
    percentageFree = 60;
    excludedPaths = [
      "Media/Music"
      "Media/Photos"
      "YoutubeCurrent"
      "Downloads.tmp"
      "Media/Kiwix"
      "Documents"
      "TimeMachine"
      ".DS_Store"
      ".cache"
    ];
  }; */

  services.auto-aspm.enable = true;
  powerManagement.powertop.enable = true;

  environment.systemPackages = with pkgs; [
    pciutils
    glances
    hdparm
    hd-idle
    hddtemp
    smartmontools
    cpufrequtils
    intel-gpu-tools
    powertop
    btop
    gptfdisk
    xfsprogs
    parted
    btrfs-progs
  ];

/*   tg-notify = {
    enable = true;
    credentialsFile = config.age.secrets.tgNotifyCredentials.path;
  }; */
}
