{
  description = "ves nixos server";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";

  outputs = { self, nixpkgs, deploy-rs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {

      nixosConfigurations.vault = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./vault ];
      };

      deploy.nodes.vault = {
        hostname = "vault.ves.dev";
        profiles.vault = {
          sshUser = "ves";
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.vault;
        };
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      devShells.${system}.default = pkgs.mkShell {
        packages = [ deploy-rs.packages.${system}.default pkgs.dogdns ];
      };
    };
}
