{
  description = "QaaxaapServer — NixOS workstation";

  inputs = {
    # stable 分支。qq 与 wechat 走仓库内自打包，不依赖 unstable。
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.workstation = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/workstation
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    };
}
