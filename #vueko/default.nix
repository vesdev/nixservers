{ modulesPath, config, pkgs, ... }: {
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
  networking.hostName = "vueko";
  networking.useDHCP = true;
  networking.domain = "";
  services.openssh.enable = true;

  system.stateVersion = "23.11";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  environment.systemPackages = [ pkgs.helix pkgs.curl pkgs.gitMinimal ];

  services.caddy = {
    enable = true;

    virtualHosts."vueko.ves.dev".extraConfig = ''
      reverse_proxy /api/* http://localhost:45861
      reverse_proxy http://localhost:3000
    '';

  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "vueko" ];
    authentication = ''
      local vueko postgres trust
    '';
    identMap = ''
      superuser_map ves postgres
      superuser_map root postgres
    '';
  };

  services.vueko-backend = {
    enable = true;
    configFile = config.age.secrets."vueko.toml".path;
  };

  services.vueko-frontend = { enable = true; };

  users.users.ves = {
    isNormalUser = true;
    extraGroups = [ "wheel" "root" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmdlbcYYILxJ2/l5o/9c7xLJZt9I5MB1WMb6Y0oktR/"
    ];
  };

  # DO NOT REMOVE OR SERVER WILL BE BRICKED  
  security.sudo.wheelNeedsPassword = false;
  nix.settings.trusted-users = [ "ves" ];
  #########################################
}
