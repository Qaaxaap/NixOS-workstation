{ config, lib, pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  # 默认会话为 Plasma。niri 会话在 sddm 里可选。
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;

  # niri 26.04 自带 niri.desktop。noctalia 5.12 由 niri 启动。
  environment.systemPackages = with pkgs; [ niri noctalia ];

  hardware.bluetooth.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    kdePackages.xdg-desktop-portal-kde
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GTK_USE_PORTAL = "1";
  };
}
