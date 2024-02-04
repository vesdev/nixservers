{
  description = "ves nixos server";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.agenix.url = "github:ryantm/agenix";

  outputs = { self, nixpkgs, deploy-rs, agenix }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {

      nixosConfigurations.vault = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          agenix.nixosModules.default
          { age.secrets."vault.env".file = ./secrets/vault.env.age; }
          ./${"#vault"}
        ];
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
        packages = [
          deploy-rs.packages.${system}.default
          pkgs.dogdns
          agenix.packages.${system}.default
        ];
      };
    };
}
