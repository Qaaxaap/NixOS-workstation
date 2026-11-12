{ config, lib, pkgs, ... }:
let
  # nvme0n1p6。子卷列表见 btrfs subvolume list /。
  disk = "/dev/disk/by-uuid/25c9b46f-dbd9-42d2-b249-7da1cf4c2a2b";

  btrfs = subvol: [
    "subvol=${subvol}"
    "compress=zstd:3"
    "ssd"
    "discard=async"
    "space_cache=v2"
  ];
in
{
  # @nixos 是新装的 NixOS 根。@ 保留给 Arch，用于回退。
  fileSystems."/" = {
    device = disk;
    fsType = "btrfs";
    options = btrfs "@nixos";
  };

  fileSystems."/home" = {
    device = disk;
    fsType = "btrfs";
    options = btrfs "@home";
  };

  # Nix store 在独立子卷。启动前必须挂载。
  fileSystems."/nix" = {
    device = disk;
    fsType = "btrfs";
    options = btrfs "@nix";
    neededForBoot = true;
  };

  # Minecraft 数据。子卷让服务数据与系统根分离。
  fileSystems."/srv" = {
    device = disk;
    fsType = "btrfs";
    options = btrfs "@srv";
  };

  fileSystems."/.snapshots" = {
    device = disk;
    fsType = "btrfs";
    options = btrfs "@snapshots";
  };

  # 共享 ESP。Windows 引导文件在 /efi/EFI/Microsoft。
  fileSystems."/efi" = {
    device = "/dev/disk/by-uuid/2D82-8163";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # Windows 数据盘。不格式化。
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/D262294662293121";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=1000"
      "umask=022"
      "windows_names"
      "nofail"
    ];
  };

  # 磁盘无交换分区。用 zram 提供交换，上限为内存的 10%。
  zramSwap.enable = true;
  zramSwap.memoryPercent = 10;

  boot.supportedFilesystems = [ "ntfs3" ];
}
