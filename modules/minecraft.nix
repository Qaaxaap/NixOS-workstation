{
  # 三个实例共用 itzg/minecraft-server。世界数据在 /srv，容器重建不影响。
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      four-person-group = {
        image = "itzg/minecraft-server";
        autoStart = false;
        ports = [
          "25565:25565"
          "25575:25575"
          "19132:19132/udp"
        ];
        volumes = [ "/srv/minecraft/four-person-group:/data" ];
        environment = {
          EULA = "true";
          TYPE = "CUSTOM";
          UID = "967";
          GID = "967";
          MAX_MEMORY = "16384M";
          INIT_MEMORY = "1024M";
          LEVEL = "world";
        };
      };

      mtr-fabric = {
        image = "itzg/minecraft-server";
        autoStart = false;
        ports = [
          "25566:25565"
          "25576:25575"
        ];
        volumes = [ "/srv/minecraft/mtr-fabric:/data" ];
        environment = {
          EULA = "true";
          TYPE = "CUSTOM";
          CUSTOM_SERVER = "/data/fabric-server-launch.jar";
          UID = "967";
          GID = "967";
          MAX_MEMORY = "8192M";
          INIT_MEMORY = "1024M";
          MODE = "survival";
          DIFFICULTY = "easy";
          LEVEL = "world";
        };
      };

      mc-tng = {
        image = "itzg/minecraft-server";
        autoStart = false;
        ports = [
          "25595:25565"
          "25596:25575"
        ];
        volumes = [ "/srv/minecraft/mc-tng:/data" ];
        environment = {
          EULA = "true";
          TYPE = "VANILLA";
          VERSION = "LATEST";
          UID = "967";
          GID = "967";
          MAX_MEMORY = "10240M";
          INIT_MEMORY = "1024M";
          MODE = "survival";
          DIFFICULTY = "hard";
          LEVEL = "world";
        };
      };

      # 临时原版服，复用 frpc-mc 隧道的本地端口（25565，主服运行时不要同时启动）。
      # 关闭正版验证，种子 1905100098，白名单默认关闭。
      mc-vanilla = {
        image = "itzg/minecraft-server";
        autoStart = false;
        ports = [ "25565:25565" ];
        volumes = [ "/srv/minecraft/mc-vanilla:/data" ];
        environment = {
          EULA = "true";
          TYPE = "VANILLA";
          VERSION = "LATEST";
          ONLINE_MODE = "false";
          SEED = "1905100098";
          UID = "967";
          GID = "967";
          MAX_MEMORY = "8192M";
          INIT_MEMORY = "1024M";
          MODE = "survival";
          LEVEL = "world";
        };
      };
    };
  };
}
