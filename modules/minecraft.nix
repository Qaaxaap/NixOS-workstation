{
  # 三个实例共用 itzg/minecraft-server。世界数据在 /srv，容器重建不影响。
  virtualisation.oci-containers = {
    backend = "docker";

    containers = {
      four-person-group = {
        image = "itzg/minecraft-server";
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
    };
  };
}
