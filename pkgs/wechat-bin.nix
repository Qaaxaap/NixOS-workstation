{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeShellWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-core,
  cups,
  glib,
  gtk3,
  jack2,
  libdrm,
  libgbm,
  libpulseaudio,
  nss,
  libxdamage,
  libGL,
  systemd,
  libxcb-keysyms,
}:

stdenv.mkDerivation {
  pname = "wechat";
  version = "4.1.13.26";

  # 沿用 AUR wechat-bin 的官方 deb 地址。
  src = fetchurl {
    url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb";
    hash = "sha256-oNuMru6NHmz+CqXOWHECcPjXSpD/SSD1Oj/CKqCVb+k=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeShellWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    cups
    glib
    gtk3
    jack2
    libdrm
    libgbm
    libpulseaudio
    nss
    libxdamage
    libxcb-keysyms
  ];

  runtimeDependencies = map lib.getLib [ systemd ];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r opt $out/opt
    cp -r usr/share $out/share

    makeShellWrapper $out/opt/wechat/wechat $out/bin/wechat \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL ]}" \
      "''${gappsWrapperArgs[@]}"

    # deb 的 desktop 指向 /usr/bin 与 /usr/share。部分 desktop 不含这些路径，替换不强制。
    for f in $out/share/applications/*.desktop; do
      substituteInPlace "$f" \
        --replace "/opt/wechat" "$out/opt/wechat" \
        --replace "/usr/share" "$out/share" \
        --replace "/usr/bin/wechat" "$out/bin/wechat"
    done

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://www.wechat.com/";
    description = "WeChat desktop from the official deb";
    license = licenses.unfree;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wechat";
  };
}
