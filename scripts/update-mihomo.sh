#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 <subscription-url>" >&2
  exit 1
fi

url=$1
out=/var/lib/mihomo/config.yaml
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

curl -fsSL -H 'User-Agent: mihomo.party/v2.0.4 (clash.meta)' "$url" -o "$tmp"

# 机场要求不要覆写 DNS 配置。这里只改运行必需的三项：
# listen 换成系统 DNS 能访问的 53 端口，ipv6 关闭避免解析出 v6，
# default-nameserver 固定为公共 IP 以打破 system 自解析循环。
nix run nixpkgs#yq-go -- -i '
  .["mixed-port"] = 7890 |
  .["external-controller"] = "127.0.0.1:9090" |
  .tun.enable = true |
  .tun.stack = "mixed" |
  .tun["auto-route"] = true |
  .tun["auto-redirect"] = true |
  .tun["auto-detect-interface"] = true |
  .tun["dns-hijack"] = ["any:53", "tcp://any:53"] |
  .tun["route-exclude-address"] = ["::/0", "100.64.0.0/10", "fd7a:115c:a1e0::/48", "192.168.0.0/16", "10.0.0.0/8", "172.16.0.0/12"] |
  .tun.mtu = 1500 |
  .dns.listen = "127.0.0.1:53" |
  .dns.ipv6 = false |
  .dns["default-nameserver"] = ["223.5.5.5", "119.29.29.29"]
' "$tmp"

install -m 600 "$tmp" "$out"
systemctl restart mihomo
echo "config updated: $out"
