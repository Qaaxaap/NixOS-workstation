#!/usr/bin/env bash
set -euo pipefail

# 用 rsync 硬链接把 @snapshots 的 root-* 快照备份到蓝盘。
# 每份快照一个目录，未变的文件通过 --link-dest 硬链接到上一份，
# 蓝盘实际占用约等于一份完整数据，而不是快照数乘以数据量。

SNAPSHOTS=/.snapshots
DEST=/mnt/data-blue/cold-arch/snapshots
DRY=false

usage() {
  cat <<'EOF'
用法: sudo ./cold-backup-root-snapshots.sh [选项]

  --dry-run  只打印计划，不实际复制
  -h, --help 显示帮助
EOF
}

for arg in "$@"; do
  case "$arg" in
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

mapfile -t snaps < <(
  find "$SNAPSHOTS" -maxdepth 1 -mindepth 1 -type d -name 'root-*' -printf '%f\n' |
    sort
)

if [ "${#snaps[@]}" -eq 0 ]; then
  echo "没有找到 root-* 快照" >&2
  exit 1
fi

echo "源快照: ${#snaps[@]} 份"
echo "目标目录: $DEST"

if ! $DRY; then
  mkdir -p "$DEST"
fi

prev=""
for name in "${snaps[@]}"; do
  src="$SNAPSHOTS/$name/"
  dst="$DEST/$name/"

  if [ -f "$DEST/$name/.backup-complete" ]; then
    echo "跳过 $name（已完成）"
    prev="$DEST/$name"
    continue
  fi

  args=(-aHAX --numeric-ids)
  if [ -n "$prev" ]; then
    args+=(--link-dest="$prev")
  fi

  if $DRY; then
    echo "[dry-run] $name${prev:+（硬链接自 $(basename "$prev")）}"
    prev="$DEST/$name"
    continue
  fi

  echo "备份 $name"
  rsync "${args[@]}" "$src" "$dst"
  touch "$DEST/$name/.backup-complete"
  prev="$DEST/$name"
done

echo "完成。目标占用:"
du -sh "$DEST" 2>/dev/null || true
df -h /mnt/data-blue | tail -1
