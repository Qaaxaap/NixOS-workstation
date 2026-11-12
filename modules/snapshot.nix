{ config, lib, pkgs, ... }:
{
  # 每天 16:30 对 /srv 与 /home 做只读快照。快照存 @snapshots 子卷。
  # NixOS 根由 configuration 与 generation 复原，不需要快照。
  systemd.services.btrfs-snapshot = {
    description = "Btrfs snapshot of /srv and /home";
    serviceConfig.Type = "oneshot";
    script = ''
      set -e
      ts=$(${pkgs.coreutils}/bin/date +%Y%m%d%H%M%S)

      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /srv /.snapshots/srv-$ts
      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /home /.snapshots/home-$ts

      # /srv 留最近 30 份。
      ls -1dt /.snapshots/srv-* | tail -n +31 | while read -r snap; do
        ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "$snap"
      done

      # /home 留最近 7 份。
      ls -1dt /.snapshots/home-* | tail -n +8 | while read -r snap; do
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
