{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ];
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "veshost";
  networking.domain = "";
  services.openssh.enable = true;

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

  system.stateVersion = "23.11";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  environment.systemPackages = [ pkgs.helix ];

  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vault.ves.dev";
      ADMIN_TOKEN =
        "wHOQMaaVRoaPVhHpZevPDM5TBTLlDWD9a06eE6+oy9TIRoBtuj6KSec+cKqZDxS+";
      ROCKET_PORT = 8222;
    };
  };

  services.caddy = {
    enable = true;

    virtualHosts."vault.ves.dev".extraConfig = ''
      reverse_proxy http://localhost:8222      
    '';

  };
}
