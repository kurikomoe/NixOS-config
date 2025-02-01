{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.frp;
  configFile = cfg.settings;
  isClient = cfg.role == "client";
  isServer = cfg.role == "server";

  isSystem = false;
in {
  options = {
    services.frp = {
      enable = lib.mkEnableOption "frp";

      package = lib.mkPackageOption pkgs "frp" {};

      role = lib.mkOption {
        type = lib.types.enum [
          "server"
          "client"
        ];
        description = ''
          The frp consists of `client` and `server`. The server is usually
          deployed on the machine with a public IP address, and
          the client is usually deployed on the machine
          where the Intranet service to be penetrated resides.
        '';
      };

      settings = lib.mkOption {
        type = lib.types.path;
        default = {};
        description = ''
          Frp configuration, for configuration options
          see the example of [client](https://github.com/fatedier/frp/blob/dev/conf/frpc_full_example.toml)
          or [server](https://github.com/fatedier/frp/blob/dev/conf/frps_full_example.toml) on github.
        '';
        example = {
          serverAddr = "x.x.x.x";
          serverPort = 7000;
        };
      };
    };
  };

  config = let
    serviceCapability = lib.optionals isServer ["CAP_NET_BIND_SERVICE"];
    executableFile =
      if isClient
      then "frpc"
      else "frps";

    frp = {
      description = "A fast reverse proxy frp ${cfg.role}";
      wants = lib.optionals isClient ["network-online.target"];
      wantedBy = ["multi-user.target"];
      after =
        if isClient
        then ["network-online.target"]
        else ["network.target"];
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 15;
        LoadCredential = "frps.toml:${configFile}";
        ExecStart = "${cfg.package}/bin/${executableFile} --strict_config -c \${CREDENTIALS_DIRECTORY}/frps.toml";
        DynamicUser = true;
      };
    };

    config_ =
      if isSystem
      then {inherit frp;}
      else {
        frp = {
          Unit = {
            Description = frp.description;
            After = frp.after;
            Wants = frp.wants;
          };

          Install.WantedBy = frp.wantedBy;

          Service = lib.removeAttrs frp.serviceConfig ["DynamicUser"];
          # Service = frp.serviceConfig;
        };
      };
  in
    lib.mkIf cfg.enable (
      if isSystem
      then {
        systemd.services = config_;
      }
      else {
        systemd.user.services = config_;
      }
    );
}
