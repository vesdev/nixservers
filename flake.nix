{
  description = "ves nixos server";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.agenix.url = "github:ryantm/agenix";
  inputs.disko.url = "github:nix-community/disko";
  inputs.vuekobot.url = "github:vesdev/vuekobot";

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      agenix,
      disko,
      vuekobot,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {

      nixosConfigurations.vueko = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          agenix.nixosModules.default
          disko.nixosModules.disko
          vuekobot.nixosModules.default
          { age.secrets."vueko.toml".file = ./secrets/vueko.toml.age; }
          {
            services.vueko-backend.package = vuekobot.packages.${system}.vueko-backend;
            services.vueko-frontend.package = vuekobot.packages.${system}.vueko-frontend;
          }
          ./${"#vueko"}
        ];
      };

      deploy.nodes.vueko = {
        hostname = "vueko.ves.dev";
        profiles.vueko = {
          sshUser = "ves";
          user = "root";
          path = deploy-rs.${system}.activate.nixos self.nixosConfigurations.vueko;
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          deploy-rs.packages.${system}.default
          pkgs.dogdns
          agenix.packages.${system}.default
        ];
      };
    };
}
