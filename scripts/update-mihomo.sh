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

nix run nixpkgs#yq-go -- -i '
  .["mixed-port"] = 7890 |
  .["external-controller"] = "127.0.0.1:9090" |
  .ipv6 = false |
  .tun.enable = true |
  .tun.stack = "mixed" |
  .tun["auto-route"] = true |
  .tun["auto-redirect"] = true |
  .tun["auto-detect-interface"] = true |
  .tun["dns-hijack"] = ["any:53", "tcp://any:53"] |
  .tun["route-exclude-address"] = ["::/0", "100.64.0.0/10", "fd7a:115c:a1e0::/48", "192.168.0.0/16", "10.0.0.0/8", "172.16.0.0/12"] |
  .tun.mtu = 1500 |
  .dns.enable = true |
  .dns.ipv6 = false |
  .dns.listen = "127.0.0.1:53" |
  .dns["enhanced-mode"] = "fake-ip" |
  .dns["fake-ip-range"] = "198.18.0.1/16"
' "$tmp"

install -m 600 "$tmp" "$out"
systemctl restart mihomo
echo "config updated: $out"
