{ config, lib, pkgs, ... }:
{
  # 每天 16:30 对 / 做只读快照。快照存 @snapshots 子卷。
  systemd.services.btrfs-snapshot = {
    description = "Btrfs snapshot of /";
    serviceConfig.Type = "oneshot";
    script = ''
      set -e
      ts=$(${pkgs.coreutils}/bin/date +%Y%m%d%H%M%S)
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r / /.snapshots/root-$ts

      # 只留最近 30 份。
      ls -1dt /.snapshots/root-* | tail -n +31 | while read -r snap; do
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "$snap"
      done
    '';
  };

  systemd.timers.btrfs-snapshot = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 16:30:00";
      Persistent = true;
    };
  };
}
