{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "bambu-studio";
  version = "02.09.01.70";

  # 上游 AppImage。x86_64 打包，Ubuntu 22.04 构建。
  src = fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/BambuStudio_ubu22_v${version}-20261103183404.AppImage";
    hash = "sha256-4N+22v4Bgba/hjW7uaexBvAvI0P45BlJ8dFWs/NiQeU=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/BambuStudio.desktop $out/share/applications/BambuStudio.desktop
    substituteInPlace $out/share/applications/BambuStudio.desktop \
      --replace-fail "Exec=AppRun" "Exec=${pname}"

    for size in 32 128 192; do
      install -Dm444 ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/BambuStudio.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/BambuStudio.png
    done
  '';

  meta = with lib; {
    description = "Bambu Lab 3D printer slicing software";
    homepage = "https://github.com/bambulab/BambuStudio";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
