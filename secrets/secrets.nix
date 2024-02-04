let
  ves =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmdlbcYYILxJ2/l5o/9c7xLJZt9I5MB1WMb6Y0oktR/";
  vault =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3vDvuXNbIVs/QrOViPto9+NIYoId68RuDrkIl8xeiS root@veshost";

in { "vault.env.age".publicKeys = [ ves vault ]; }
