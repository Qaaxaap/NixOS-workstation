{ config, lib, pkgs, ... }:
let
  sidecar = "${pkgs.clash-party}/share/clash-party/sidecar";

  # 上游检查内核的 setuid 位与 root 属主来判断 TUN 权限。
  # permissions 必须放开 go+rx，默认只允许 root 执行。
  mkWrapper = name: {
    source = "${sidecar}/${name}";
    setuid = true;
    owner = "root";
    group = "root";
    permissions = "u+rx,go+rx";
  };
in
{
  security.wrappers = {
    clash-party-mihomo = mkWrapper "mihomo";
    clash-party-mihomo-alpha = mkWrapper "mihomo-alpha";
    clash-party-mihomo-smart = mkWrapper "mihomo-smart";
  };
}
