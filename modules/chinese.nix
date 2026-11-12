{ config, lib, pkgs, ... }:
{
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };
  i18n.supportedLocales = [
    "zh_CN.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      (fcitx5-rime.override {
        rimeDataPkgs = [ rime-ice rime-data ];
      })
    ];
    fcitx5.waylandFrontend = true;
  };

  # KDE 的 fcitx5 启动器直接运行普通 fcitx5 包，绕过了 with-addons 的 wrapper，
  # 缺少这个变量时 rime 插件加载失败，输入法显示“中州韵（不可用）”。
  environment.variables.FCITX_ADDON_DIRS = "${config.i18n.inputMethod.package}/lib/fcitx5";

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      wqy_zenhei
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      maple-mono.NF-CN-unhinted
      nanum
    ];
    fontconfig.defaultFonts = {
      sansSerif = [ "Noto Sans CJK SC" ];
      serif = [ "Noto Serif CJK SC" ];
    };
  };
}
