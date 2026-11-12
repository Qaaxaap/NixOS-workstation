{ config, lib, pkgs, ... }:
{
  # Mihomo Party 的 Linux TUN 依赖内核 sidecar 二进制的 setuid root 位。
  # store 是 ro,nosuid，内核在打包时移到 share，这里复制到 /var/lib 并设置 setuid。
  # resources/sidecar 是指向 /var/lib 的符号链接，GUI 的权限检查会跟随并看到 setuid。
  systemd.services.clash-party-tun = {
    description = "Install clash-party mihomo cores with setuid for TUN mode";

    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = toString (
        pkgs.writeShellScript "clash-party-tun" ''
          set -eu

          src=${pkgs.clash-party}/share/clash-party/sidecar
          dst=/var/lib/clash-party/sidecar

          mkdir -p "$dst"
          cp -f "$src"/* "$dst"/

          chown -R root:root /var/lib/clash-party
          chmod +sx "$dst"/mihomo "$dst"/mihomo-alpha "$dst"/mihomo-smart
          chmod 755 "$dst"/*.node
        ''
      );
    };
  };
}
