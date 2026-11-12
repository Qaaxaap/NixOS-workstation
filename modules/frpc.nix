{ config, lib, pkgs, ... }:
let
  tokenFile = "/var/lib/frpc/token";

  unit = name: tunnelId: {
    description = "OpenFrp tunnel ${name}";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
      ExecStart = "${pkgs.writeShellScript "frpc-${name}" ''
        exec ${pkgs.frpc-of}/bin/frpc-of -n -u "$(cat ${tokenFile})" -p ${tunnelId}
      ''}";
    };
  };
in
{
  # 首次部署后写入访问密钥：echo TOKEN > /var/lib/frpc/token
  systemd.tmpfiles.rules = [
    "d /var/lib/frpc 0700 root root - -"
    "f ${tokenFile} 0600 root root - -"
  ];

  # 三条隧道：SSH、MC 主服、Aeronautics 服。
  systemd.services = {
    frpc-ssh = unit "ssh" "1208610";
    frpc-mc = unit "mc" "1208618";
    frpc-aeronautics = unit "aeronautics" "1234928";
  };
}
