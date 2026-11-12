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
  libayatana-appindicator,
  libdrm,
  libgbm,
  libgcrypt,
  libkrb5,
  libnotify,
  libpulseaudio,
  libssh2,
  libGL,
  libuuid,
  nss,
  libxdamage,
  systemd,
}:

stdenv.mkDerivation {
  pname = "linuxqq";
  version = "3.2.35";

  # 沿用 AUR linuxqq 的下载路径。nixpkgs 26.05 的旧路径已返回 403。
  src = fetchurl {
    url = "https://qqdl.gtimg.cn/qqfile/QQNT/9.9.37/beta/816b3c79/linuxqq_3.2.35-54395_amd64.deb";
    hash = "sha256-feA4YjJ6u9FtonEwQTaYyVF3grJxlK/Fk7w6v5tV+aw=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeShellWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    cups
    glib
    gtk3
    libdrm
    libpulseaudio
    libgcrypt
    libkrb5
    libgbm
    nss
    libxdamage
  ];

  runtimeDependencies = map lib.getLib [
    systemd
    libkrb5
  ];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r opt $out/opt
    cp -r usr/share $out/share

    substituteInPlace $out/share/applications/qq.desktop \
      --replace-fail "/opt/QQ/qq" "$out/bin/qq" \
      --replace-fail "/usr/share" "$out/share"

    makeShellWrapper $out/opt/QQ/qq $out/bin/qq \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix LD_PRELOAD : "${lib.makeLibraryPath [ libssh2 ]}/libssh2.so.1" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libGL
          libuuid
        ]
      }" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      "''${gappsWrapperArgs[@]}"

    rm -r $out/opt/QQ/resources/app/libssh2.so.1

    # 托盘与通知。上游 deb 不会带这两个库的软链。
    ln -s ${libayatana-appindicator}/lib/libayatana-appindicator3.so \
      $out/opt/QQ/libappindicator3.so
    ln -s ${libnotify}/lib/libnotify.so \
      $out/opt/QQ/libnotify.so

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://im.qq.com/";
    description = "Linux QQ from the official deb";
    license = licenses.unfree;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "qq";
  };
}
