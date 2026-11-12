{
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "frpc-of";
  version = "0.68.0";

  # 静态链接的 OpenFrp 客户端。文件放在仓库 vendor 目录。
  src = ../vendor/frpc_linux_amd64;

  dontUnpack = true;

  installPhase = ''
    install -Dm755 $src $out/bin/frpc-of
  '';

  meta = with lib; {
    description = "OpenFrp frpc client";
    homepage = "https://www.openfrp.net";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "frpc-of";
  };
}
