let
  ves = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKmdlbcYYILxJ2/l5o/9c7xLJZt9I5MB1WMb6Y0oktR/";
  vesdev = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbC6wlxXiAqrxQ9ydIRxZ7rGbjn0dRMaVPD5c/mLQzK root@vueko
";
in
{
  "vueko.toml.age".publicKeys = [
    ves
    vesdev
  ];

  "spambotsen.toml.age".publicKeys = [
    ves
    vesdev
  ];
}
