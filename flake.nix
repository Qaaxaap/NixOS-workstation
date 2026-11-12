{
  description = "QaaxaapServer — NixOS workstation";

  inputs = {
    # stable 分支。qq 与 wechat 走仓库内自打包，不依赖 unstable。
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      config = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/workstation
        ];
      };
    in
    {
      # 主机名与 QaaxaapServer 一致，nh 的默认推断可直接命中。
      # workstation 保留作语义别名，nixos-rebuild 两种写法都可用。
      nixosConfigurations = {
        QaaxaapServer = config;
        workstation = config;
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    };
}
