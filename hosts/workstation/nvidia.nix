{
  # 4070 SUPER 用开源内核模块。26.05 latest 分支为 595.x。
  hardware.nvidia = {
    open = true;
    branch = "latest";
    modesetting.enable = true;
    nvidiaSettings = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
}
