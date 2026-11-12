{
  # chatapi 由用户 profile 提供。先运行 nix profile install 再启动本服务。
  systemd.services.chatapi = {
    description = "ChatAPI server";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "Qaaxaap";
      WorkingDirectory = "/home/Qaaxaap/Projects/ChatAPI/backend";
      EnvironmentFile = "/home/Qaaxaap/Projects/ChatAPI/backend/.env";
      ExecStart = "/home/Qaaxaap/.nix-profile/bin/chatapi";
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 20;
    };
  };
}
