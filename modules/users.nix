{ config, lib, pkgs, ... }:
{
  # 保留原 uid。@home 内文件属主不变。
  users.users.Qaaxaap = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/Qaaxaap";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMWevQFKpxhWUyAtrZjGUXhOQuqs0aRC6bwiqGapBU45 lkn15289353760@126.com"
    ];
  };

  # 独立普通用户。首次 rebuild 后用 passwd 设置密码。
  users.users.Vesperon = {
    isNormalUser = true;
    home = "/home/Vesperon";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE4Vimo5eLFJSVwFUgZ8fReBRPavqYYEVhp+OVVQ9Y11 Vesperon@cfc8522bc8db.ofalias.net"
    ];
  };

  # 仅 SSH。保留 uid 955，@home 属主不变。NixOS 不允许普通用户 uid 小于 1000。
  users.users.Pulsar = {
    isSystemUser = true;
    uid = 955;
    group = "Pulsar";
    home = "/home/Pulsar";
    createHome = false;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBBc/g+0NYMbVqusGPoKXLpKaqdRX5glhT14b1M7f+5W client-key"
    ];
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
