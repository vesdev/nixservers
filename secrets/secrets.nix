let
  ves =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmdlbcYYILxJ2/l5o/9c7xLJZt9I5MB1WMb6Y0oktR/";
  vueko =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKPxdY78wHZiy78OkDCRUjDUyPso3m5h4ZFqyPjSCSW6 root@vueko";

in { "vueko.toml.age".publicKeys = [ ves vueko ]; }
