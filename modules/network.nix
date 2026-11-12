{
  networking.networkmanager.enable = true;

  # 所有端口只对本机局域网开放。frp 隧道另走出站连接。
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      2222
      25565
      25566
      25575
      25576
      25595
      25596
      5000
    ];
    allowedUDPPorts = [ 19132 ];
    trustedInterfaces = [ "tailscale0" "docker0" ];
  };

  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    settings = {
      PermitRootLogin = "no";
      # 临时允许密码登录。frp 隧道把 2222 暴露到公网，用完改回 false。
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
    };
  };

  services.tailscale.enable = true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
}
