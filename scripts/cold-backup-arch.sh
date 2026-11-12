#!/usr/bin/env bash
set -euo pipefail

# 把 @snapshots 里的 root-* 快照冷备份到蓝盘。
# 默认只备份最近的 3 个，--all 备份全部。已存在的快照会跳过。
# 优先尝试 btrfs send -p 增量，失败时自动退回完整发送。

SNAPSHOTS=/.snapshots
DEST=/mnt/data-blue/cold-arch
ALL=false
DRY=false

usage() {
  cat <<'EOF'
用法: sudo ./cold-backup-arch.sh [选项]

  --all      备份全部 root-* 快照（默认只备份最近 3 个）
  --dry-run  只打印计划，不实际发送
  -h, --help 显示帮助
EOF
}

for arg in "$@"; do
  case "$arg" in
    --all) ALL=true ;;
    --dry-run) DRY=true ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done

if [ "$(id -u)" -ne 0 ]; then
  echo "需要 root 权限运行" >&2
  exit 1
fi

if ! mountpoint -q /mnt/data-blue; then
  echo "蓝盘未挂载在 /mnt/data-blue" >&2
  exit 1
fi

if [ ! -d "$SNAPSHOTS" ]; then
  echo "快照目录不存在: $SNAPSHOTS" >&2
  exit 1
fi

mapfile -t snaps < <(
  find "$SNAPSHOTS" -maxdepth 1 -mindepth 1 -type d -name 'root-*' -printf '%f\n' |
    sort
)

if [ "${#snaps[@]}" -eq 0 ]; then
  echo "没有找到 root-* 快照" >&2
  exit 1
fi

if ! $ALL && [ "${#snaps[@]}" -gt 3 ]; then
  snaps=("${snaps[@]: -3}")
fi

echo "目标目录: $DEST"
echo "计划快照数: ${#snaps[@]}"

if ! $DRY; then
  mkdir -p "$DEST"
fi

prev=""
for name in "${snaps[@]}"; do
  src="$SNAPSHOTS/$name"

  if [ -e "$DEST/$name" ]; then
    echo "跳过 $name（目标已存在）"
    prev="$name"
    continue
  fi

  if $DRY; then
    if [ -n "$prev" ] && [ -e "${DEST:-/nonexistent}/$prev" ]; then
      echo "[dry-run] 增量发送 $name（父 $prev）"
    else
      echo "[dry-run] 完整发送 $name"
    fi
    prev="$name"
    continue
  fi

  if [ -n "$prev" ] && [ -e "$DEST/$prev" ]; then
    echo "增量发送 $name（父 $prev）"
    if btrfs send -p "$SNAPSHOTS/$prev" "$src" | btrfs receive "$DEST"; then
      prev="$name"
      continue
    fi
    echo "增量失败，改为完整发送 $name" >&2
  fi

  echo "完整发送 $name"
  btrfs send "$src" | btrfs receive "$DEST"
  prev="$name"
done

echo "完成。蓝盘占用:"
df -h /mnt/data-blue | tail -1
