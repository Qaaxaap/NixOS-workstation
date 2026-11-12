{ config, lib, pkgs, ... }:
{
  # 保留原 uid。@home 内文件属主不变。
  users.users.Qaaxaap = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/Qaaxaap";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  # 仅 SSH。保留 uid 955，@home 属主不变。NixOS 不允许普通用户 uid 小于 1000。
  users.users.Pulsar = {
    isSystemUser = true;
    uid = 955;
    group = "Pulsar";
    home = "/home/Pulsar";
    createHome = false;
    shell = pkgs.zsh;
  };
  users.groups.Pulsar.gid = 955;

  # 容器以 967 运行。宿主机 uid 与容器一致。
  users.users.minecraft = {
    isSystemUser = true;
    uid = 967;
    group = "minecraft";
    home = "/srv/minecraft";
    shell = pkgs.bash;
  };
  users.groups.minecraft.gid = 967;

  programs.zsh.enable = true;
}
