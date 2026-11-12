# 构建系统，不切换。
build:
    sudo nixos-rebuild build --flake .#workstation

# 切换系统。
switch:
    sudo nixos-rebuild switch --flake .#workstation

# 只更新引导，下次启动生效。
boot:
    sudo nixos-rebuild boot --flake .#workstation

# 格式化 nix 文件。
fmt:
    nix fmt
