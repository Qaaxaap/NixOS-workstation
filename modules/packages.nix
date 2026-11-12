{ config, lib, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  # ventoy 1.1.12 被标为 insecure。它只在本机做启动盘，风险可接受。
  nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.12" ];

  programs.steam.enable = true;
  programs.dconf.enable = true;

  # 允许运行预编译的动态链接程序。VSCodium Remote 的 server 需要它。
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    # 基础工具
    _7zz
    git
    gnumake
    unzip
    ripgrep
    fd
    fzf
    nix-output-monitor
    direnv
    alsa-tools
    alsa-utils
    bmon
    btrfs-progs
    dosfstools
    hdparm
    htop
    fastfetch
    lsof
    man-db
    mtools
    ntfs3g
    ntfsprogs
    tree
    jq
    wget
    rsync
    vim
    neovim

    # 开发工具
    clang
    gcc
    gdb
    cmake
    ninja
    clang-tools
    just
    github-cli
    ruff
    pyright
    platformio-core
    nodejs
    pnpm

    # KDE 应用
    kdePackages.ark
    kdePackages.dolphin
    kdePackages.konsole
    kdePackages.filelight
    kdePackages.gwenview
    kdePackages.kio-admin

    # 桌面
    kitty
    blueman
    fuzzel

    # 图形与媒体
    gimp
    inkscape
    blender
    freecad

    # 国民应用
    qq
    wechat
    vscodium
    firefox
    chromium

    # 代理与网络
    clash-party
    tailscale

    # 游戏
    steam
    wine
    winetricks

    # 3D 打印
    bambu-studio-bin
    orca-slicer

    # 硬件工具
    i7z
    s-tui
    linuxPackages.turbostat
    hashcat
    john
    wchisp

    # AI 与数据处理
    micromamba
    jupyter
    python3

    # 虚拟化
    qemu
    libguestfs

    # 启动盘工具
    ventoy

    # 输入法
    fcitx5
    fcitx5-gtk
    qt6Packages.fcitx5-qt
    qt6Packages.fcitx5-configtool
  ];
}
