{
  description = "ves nixos server";

  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    agenix.url = "github:ryantm/agenix";
    disko.url = "github:nix-community/disko";
    spambotsen.url = "github:vesdev/spambotsen";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self
    , nixpkgs
    , deploy-rs
    , agenix
    , disko
    , spambotsen
    ,
    }:
    let
      system = "x86_64-linux";
      system-aarch = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      # netcup
      nixosConfigurations.vesdev = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit spambotsen;
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

      # pi3
      nixosConfigurations.pi3 = nixpkgs.lib.nixosSystem {
        system = system-aarch;
        modules = [
          agenix.nixosModules.default
          disko.nixosModules.disko
          ./${"#pi3"}
        ];
      };

      deploy.nodes.pi3 = {
        hostname = "pi3";
        profiles.pi3 = {
          sshUser = "ves";
          user = "root";
          path = deploy-rs.lib.${system-aarch}.activate.nixos self.nixosConfigurations.pi3;
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
