{
  description = "Feishin music player";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.feishin = pkgs.buildNpmPackage {
          pname = "feishin";
          version = "1.12.0";
          src = ./.;

          npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will need adjustment

          # Force copy the lock file as package-lock.json
          # before the npm-deps build starts.
          # To satisfy buildNpmPackage, I will vendor the lockfile
          # in the root so it is found in the source directory.
          postUnpack = ''
            cp $sourceRoot/pnpm-lock.yaml $sourceRoot/package-lock.json
          '';

          nativeBuildInputs = [
            pkgs.nodejs_22
            pkgs.pnpm_9
          ];

          # Inject CA bundle for SSL verification
          env = {
            NODE_EXTRA_CA_CERTS = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
          };

          buildPhase = ''
            export HOME=$TMPDIR
            npm install --frozen-lockfile
            npm run build:remote
          '';

          installPhase = ''
            mkdir -p $out/share/feishin
            cp -r out/remote/* $out/share/feishin/
          '';
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
