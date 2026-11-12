{ config, lib, pkgs, ... }:
{
  # ESP 与 Windows 共用。写入 EFI 变量会改启动顺序。
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/efi";

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;

    # os-prober 找不到 Arch。Arch 内核在 @ 子卷内，没有独立 /boot 分区。
    # 直接链到 Arch 的 GRUB EFI。
    extraEntries = ''
      menuentry "Arch Linux (fallback)" {
        insmod chain
        chainloader /EFI/Arch/grubx64.efi
      }
    '';
  };

  # 26.05 默认内核对 14900K 与 4070 SUPER 可用。
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = [ "loglevel=5" ];
}
