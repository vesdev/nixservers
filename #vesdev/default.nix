{ modulesPath, pkgs, config, spambotsen, ... }: {

  imports = with import ../users.nix; [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk.nix
    spambotsen.nixosModules.default

    # users
    ves
  ];
  security.sudo.wheelNeedsPassword = false;

  boot.loader.grub = { efiSupport = true; efiInstallAsRemovable = true; };
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "vesdev";
  networking.useDHCP = true;
  networking.domain = "";
  services.openssh.enable = true;

  system.stateVersion = "24.05";

  age.secrets.spambotsen.file = ../secrets/spambotsen.toml.age;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
  };

  environment.systemPackages = with pkgs; [
    helix
    curl
    gitMinimal
    bottom
  ];

  services.caddy = {
    enable = true;

    virtualHosts."ves.dev".extraConfig = ''
      redir https://github.com/vesdev
    '';

    virtualHosts."share.ves.dev".extraConfig = ''
      reverse_proxy localhost:8040
    '';
  };

  services.spambotsen = {
    enable = true;
    package = spambotsen.packages.${pkgs.system}.default;
    configFile = config.age.secrets.spambotsen.path;
  };

  services.microbin = {
    enable = true;
    settings = {
      MICROBIN_PORT = 8040;
    };
  };
}
