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
    enable = mkEnableOption "Feishin web application service";

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The host to bind the Feishin web application to.";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "The port to bind the Feishin web application to.";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Declarative settings for the Feishin web application.
        These settings will be converted to a JSON configuration file.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.feishin;
      defaultText = literalExpression "pkgs.feishin";
      description = "The Feishin package to use.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.feishin = {
      description = "Feishin web application";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "feishin";
        Group = "feishin";
        WorkingDirectory = "/var/lib/feishin";
        ExecStart = "${pkgs.nodejs}/bin/node ${pkgs.nodePackages.http-server}/bin/http-server ${cfg.package}/share/feishin/web -p ${toString cfg.port} -a ${cfg.host}";
        Restart = "on-failure";
      };
      preStart = ''
        # Create settings file from Nix configuration
        mkdir -p /var/lib/feishin
        cat > /var/lib/feishin/settings.json <<EOF
        ${builtins.toJSON cfg.settings}
        EOF
      '';
    };

    users.users.feishin = {
      isSystemUser = true;
      group = "feishin";
      description = "Feishin service user";
    };

    users.groups.feishin = { };

    networking.firewall.allowedTCPPorts = mkIf (cfg.port != 80 && cfg.port != 443) [ cfg.port ];
  };
}
