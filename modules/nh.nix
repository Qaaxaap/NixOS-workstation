{ config, lib, pkgs, ... }:
{
  # nh 管理日常 rebuild 与清理。
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 3d";
    };
    flake = "/home/Qaaxaap/Projects/NixOS-workstation";
  };
}
