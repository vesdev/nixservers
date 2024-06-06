{
  description = "ves nixos server";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.agenix.url = "github:ryantm/agenix";
  inputs.disko.url = "github:nix-community/disko";
  inputs.websurfx.url = "github:neon-mmd/websurfx";
  inputs.websurfx.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      agenix,
      disko,
      websurfx,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {

      nixosConfigurations.vesdev = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit websurfx;
        };
        modules = [
          agenix.nixosModules.default
          disko.nixosModules.disko
          ./${"#vesdev"}
        ];
      };

      deploy.nodes.vesdev = {
        hostname = "ves.dev";
        profiles.vesdev = {
          sshUser = "ves";
          user = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.vesdev;
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
