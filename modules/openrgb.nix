{ config, lib, pkgs, ... }:
{
  # OpenRGB：主板 Aura（hidraw）与内存 RGB（i2c SMBus）控制。
  # 开机关灯由 BIOS 的 Aura 设置完成，这里只保留手动控制能力。
  boot.kernelModules = [ "i2c-dev" ];

  environment.systemPackages = [ pkgs.openrgb ];
  services.udev.packages = [ pkgs.openrgb ];
}
