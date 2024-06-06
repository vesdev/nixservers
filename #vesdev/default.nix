{
  modulesPath,
  pkgs,
  config,
  websurfx,
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

    virtualHosts."search.ves.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:5050
    '';
  };

  services.kavita = {
    enable = true;
    tokenKeyFile = config.age.secrets.kavita.path;
  };

  services.redis.servers.websurfx = {
    enable = true;
    # user = "websurfx";
    port = 8082;
  };

  systemd.services.websurfx = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    wants = [ "network-online.target" ];
    restartIfChanged = true;

    serviceConfig = {
      user = "websurfx";
      group = "websurfx";
      restart = "always";
      WorkingDirectory =
        let
          public = pkgs.stdenv.mkDerivation {
            name = "websurfx-public";
            src = websurfx;
            phases = [ "installPhase" ];
            installPhase = ''
              mkdir -p $out
              cp -r $src/public $out
            '';
          };
        in
        public;

      ExecStart = "${websurfx.packages.${pkgs.system}.default}/bin/websurfx";
    };
  };

  environment.etc = {
    "xdg/websurfx/config.lua".text = # lua
      ''
        -- general
        logging = true
        debug = false
        threads = 1

        -- server
        port = 5050
        binding_ip = "127.0.0.1"
        production_use = true
        request_timeout = 30
        tcp_connection_keep_alive = 30
        pool_idle_connection_timeout = 30

        rate_limiter = {
        	number_of_requests = 20,
        	time_limit = 3,
        }
        https_adaptive_window_size = false
        client_connection_keep_alive = 120

        -- search
        safe_search = 0

        -- website
        colorscheme = "tokyo-night"
        theme = "simple"
        animation = "simple-frosted-glow"

        -- caching
        redis_url = "redis://127.0.0.1:8082"
        cache_expiry_time = 600

        -- search engines
        upstream_search_engines = {
          DuckDuckGo = true,
          Searx = true,
          Brave = true,
          Startpage = true,
        }
      '';
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
