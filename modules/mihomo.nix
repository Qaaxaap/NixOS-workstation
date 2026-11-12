{ config, lib, pkgs, ... }:
{
  # mihomo 内核作为系统服务运行，TUN 与 DNS 由内核接管。
  # 配置需手动放置到 /var/lib/mihomo/config.yaml，更新用仓库内 scripts/update-mihomo.sh。
  # 与 clash-party GUI 的 TUN 冲突，启用本服务时不要启动 GUI。
  systemd.services.mihomo = {
    description = "Mihomo (clash meta) proxy core";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      # metacubexd 是 mihomo 官方 web 面板，通过 9090 的 /ui/ 提供。
      ExecStart = "${lib.getExe pkgs.mihomo} -d /var/lib/mihomo -f /var/lib/mihomo/config.yaml -ext-ui ${pkgs.metacubexd}";
      Restart = "on-failure";
      RestartSec = 5;
      StateDirectory = "mihomo";
    };
  };

  # nftables 相关内核模块。NixOS 默认只懒加载一部分，重启后缺失这些模块时
  # mihomo 的 auto-redirect 会失败并降级纯 TUN（不建策略路由），本机流量直连被墙。
  boot.kernelModules = [
    "nft_nat"
    "nft_redir"
    "nft_chain_nat"
    "nft_socket"
    "nft_fib"
    "nft_fib_inet"
    "nft_fib_ipv4"
    "nft_fib_ipv6"
    "nft_queue"
    "nft_tproxy"
    "nft_log"
    "nft_counter"
  ];

  # 系统 DNS 交给 mihomo。fake-ip 只回 A 记录，应用不会产生 IPv6 连接。
  networking.networkmanager.dns = "none";
  networking.resolvconf.enable = true;
  networking.resolvconf.useLocalResolver = true;

  # tailscale 不再接管 DNS，避免覆盖 resolv.conf。
  services.tailscale.extraSetFlags = [ "--accept-dns=false" ];

  # TUN 流量不经过防火墙反向路径检查。
  networking.firewall.trustedInterfaces = [ "Mihomo" ];
  networking.firewall.checkReversePath = "loose";
}
