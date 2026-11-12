{ config, lib, pkgs, ... }:
{
  # Mihomo Party 的 Linux TUN 依赖内核 sidecar 二进制的 setuid root 位。
  # 上游用 pkexec 完成授权，Nix store 不可变，所以由 systemd 在每次启动时重新设置。
  # rebuild 后包路径变化时，本服务随 switch 重启，处理新路径。
  systemd.services.clash-party-tun = {
    description = "Grant setuid root to clash-party mihomo cores for TUN mode";

    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = toString (
        pkgs.writeShellScript "clash-party-tun" ''
          set -eu

          sidecar=${
            pkgs.clash-party
          }/opt/clash-party/resources/sidecar

          for core in mihomo mihomo-alpha mihomo-smart; do
            if [ -f "$sidecar/$core" ]; then
              chown root:root "$sidecar/$core"
              chmod +sx "$sidecar/$core"
            fi
          done
        ''
      );
    };
  };
}
