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
      frpc-of = final.callPackage ../../pkgs/frpc-of.nix { };
    })
  ];

  # 国内镜像。软件源顺序即优先级。
  nix.settings = {
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
