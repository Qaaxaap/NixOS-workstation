{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # NVMe 盘在 RST VMD 控制器下，initrd 必须带 vmd，否则找不到根盘。
  # 其余模块来自 nixos-generate-config，另补 USB 存储与 2.5G 网卡。
  boot.initrd.availableKernelModules = [
    "vmd"
    "xhci_pci"
    "ahci"
    "nvme"
    "uas"
    "usb_storage"
    "sd_mod"
    "r8169"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  # i9-14900K。加载 Intel 微码。
  hardware.cpu.intel.updateMicrocode = true;

  # RTL8125 网卡与 Intel AX201 无线网卡需要固件。
  hardware.enableRedistributableFirmware = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
