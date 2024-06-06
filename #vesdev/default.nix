{
  modulesPath,
  pkgs,
  config,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk.nix
  ];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "vesdev";
  networking.useDHCP = true;
  networking.domain = "";
  services.openssh.enable = true;

  system.stateVersion = "24.05";

  age.secrets.kavita.file = ../secrets/kavita.age;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
  };

  environment.systemPackages = [
    pkgs.helix
    pkgs.curl
    pkgs.gitMinimal
  ];

  services.caddy = {
    enable = true;

    virtualHosts."kavita.ves.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:5000
    '';
  };

  services.kavita = {
    enable = true;
    # settings.port = 5000;
    # settings.ip = "127.0.0.1";
    tokenKeyFile = config.age.secrets.kavita.path;
  };

  users.users.ves = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "root"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmdlbcYYILxJ2/l5o/9c7xLJZt9I5MB1WMb6Y0oktR/"
    ];
  };

  # DO NOT REMOVE OR SERVER WILL BE BRICKED  
  security.sudo.wheelNeedsPassword = false;
  nix.settings.trusted-users = [ "ves" ];
  #########################################
}
