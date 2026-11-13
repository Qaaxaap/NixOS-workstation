{ config, lib, pkgs, ... }:
{
  # OpenRGB：主板 Aura（hidraw）与内存 RGB（i2c SMBus）控制。
  # 开机后统一把主板和内存灯设为 Off。
  boot.kernelModules = [ "i2c-dev" ];

  environment.systemPackages = [ pkgs.openrgb ];
  services.udev.packages = [ pkgs.openrgb ];

  systemd.services.openrgb-off = {
    description = "Turn off motherboard and DRAM RGB";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # boot.kernelModules 只在启动时加载，服务里再确保一次。
      ExecStartPre = "${pkgs.kmod}/bin/modprobe i2c-dev";
    };
    script = ''
      sleep 3
      for i in 0 1 2 3; do
        ${pkgs.openrgb}/bin/openrgb --device "$i" --mode Off || true
      done
    '';
  };
}
