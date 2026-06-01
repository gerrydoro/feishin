{
  description = "Feishin music player";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pnpm2nix.url = "github:nix-community/pnpm2nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pnpm2nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        pnpm2nix = import pnpm2nix.inputs.pnpm2nix { inherit pkgs; };
      in
      {
        packages.feishin = pnpm2nix.buildPackage {
          src = ./.;
          pname = "feishin";
          version = "1.12.0";

          # Use pnpm2nix to handle dependencies
          # It generates the derivation from pnpm-lock.yaml

          buildPhase = ''
            export HOME=$TMPDIR
            # pnpm2nix installs dependencies automatically
            # We just need to build the project
            pnpm run build:remote
          '';

          installPhase = ''
            mkdir -p $out/share/feishin
            cp -r out/remote/* $out/share/feishin/
          '';

          # Inject CA bundle for SSL verification
          env = {
            NODE_EXTRA_CA_CERTS = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
          };
        };
      }
    )
    // {
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        with lib;
        let
          cfg = config.services.feishin;
        in
        {
          options.services.feishin = {
            enable = mkEnableOption "Feishin music player web interface";
            host = mkOption {
              type = types.str;
              default = "127.0.0.1";
              description = "Host to listen on";
            };
            port = mkOption {
              type = types.port;
              default = 8080;
              description = "Port to listen on";
            };
            settings = mkOption {
              type = types.attrsOf types.anything;
              default = { };
              description = "Declarative settings for Feishin";
            };
          };

          config = mkIf cfg.enable {
            systemd.services.feishin = {
              description = "Feishin music player";
              wantedBy = [ "multi-user.target" ];
              serviceConfig = {
                ExecStart = "${pkgs.nginx}/bin/nginx -c ${pkgs.writeText "nginx.conf" ''
                  daemon off;
                  error_log /dev/stderr info;
                  pid /tmp/nginx.pid;
                  events { worker_connections 1024; }
                  http {
                    include ${pkgs.nginx}/conf/mime.types;
                    server {
                      listen ${cfg.host}:${toString cfg.port};
                      root ${self.packages.${pkgs.system}.feishin}/share/feishin;
                      index index.html;
                      location / {
                        try_files $uri $uri/ /index.html;
                      }
                    }
                  }
                ''}";
              };
            };
          };
        };
    };
}
