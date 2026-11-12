{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./disk.nix
    ./boot.nix
    ./nvidia.nix

    ../../modules/users.nix
    ../../modules/network.nix
    ../../modules/desktop.nix
    ../../modules/chinese.nix
    ../../modules/packages.nix
    ../../modules/minecraft.nix
    ../../modules/frpc.nix
    ../../modules/chatapi.nix
    ../../modules/snapshot.nix
    ../../modules/nh.nix
  ];

  # 仓库内自打包的包。
  nixpkgs.overlays = [
    (final: prev: {
      clash-party = final.callPackage ../../pkgs/clash-party.nix { };
      bambu-studio-bin = final.callPackage ../../pkgs/bambu-studio-bin.nix { };

      # 26.05 自带的 qq 与 wechat 下载 URL 失效，用自打包的 deb 版本。
      qq = final.callPackage ../../pkgs/qq-bin.nix { };
      wechat = final.callPackage ../../pkgs/wechat-bin.nix { };
      frpc-of = final.callPackage ../../pkgs/frpc-of.nix { };
    })
  ];

  # 国内镜像。软件源顺序即优先级。
  # 国内镜像。软件源顺序即优先级。
  nix.settings = {
    # nh 与 nixos-rebuild 内部调用需要。缺了 nix profile 会报未启用。
    experimental-features = [ "nix-command" "flakes" ];

    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    trusted-users = [ "root" "Qaaxaap" ];
  };

  networking.hostName = "QaaxaapServer";
  time.timeZone = "Asia/Shanghai";

  # 首次安装后不改此值。
  system.stateVersion = "26.05";
}
