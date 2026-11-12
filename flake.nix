{
  description = "QaaxaapServer — NixOS workstation";

  inputs = {
    # stable 分支，系统主体用这个。
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # 26.05 里 qq 与 wechat 的下载 URL 已失效。用 unstable 的这两个包覆盖。
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.workstation = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit unstable; };
        modules = [
          ./hosts/workstation
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    };
}
