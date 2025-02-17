{
  ves = {
    users.users.ves = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "root"
      ];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmdlbcYYILxJ2/l5o/9c7xLJZt9I5MB1WMb6Y0oktR/ ves@nixos-pc"
      ];
    };

    nix.settings.trusted-users = [ "ves" ];
  };

  poju = {
    users.users.poju = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "root"
      ];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7GEa+/sKxbZuwkMZ7qR1Cqxe0vozNvRxQJlyi4hB+L poju@perjantai"
      ];
    };

    nix.settings.trusted-users = [ "poju" ];
  };
}
