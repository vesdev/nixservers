{ modulesPath, pkgs, ... }: {

  imports = with import ../users.nix; [
    (modulesPath + "/installer/scan/not-detected.nix")

    # users
    ves
    poju
  ];

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "24.05";
  zramSwap.enable = true;
  hardware.enableRedistributableFirmware = true;

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/mnt/hdd" = {
      device = "/dev/disk/by-uuid/6056ab3b-f8ab-4434-b931-25e97ac0ea8a";
      fsType = "ext4";
    };
  };

  networking = {
    hostName = "pi3";
    useDHCP = true;
    wireless.iwd.enable = true;
    wireless.iwd.settings = {
      IPv6.Enabled = true;
      Settings.AutoConnect = true;
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        4000
      ];
      allowedUDPPorts = [ 53 ];
      allowPing = true;
    };
  };

  services = {
    openssh.enable = true;

    # blocky as dns proxy for quad9
    blocky = {
      enable = true;
      settings = {

        ports = {
          dns = 53;
          http = 4000;
        };

        upstreams.groups.default =
          [
            "9.9.9.9"
            "149.112.112.112"
            "https://dns.quad9.net/dns-query"
            "tcp-tls:dns.quad9.net"
          ];

        blocking = {
          denylists.ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          ];

          clientGroupsBlock.default = [
            "ads"
          ];
        };

      };
    };
  };

  # samba NAS
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        "hosts allow" = "192.168.178. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "public" = {
        "path" = "/mnt/hdd/Shares/Public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0777";
        "directory mask" = "0777";
        "force user" = "ves";
        "force group" = "wheel";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    helix
    curl
    gitMinimal
    bottom
  ];
}
