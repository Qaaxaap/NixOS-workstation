{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  nss,
  nspr,
  alsa-lib,
  openssl,
  webkitgtk_4_1,
  udev,
  libayatana-appindicator,
  libGL,
  libgbm,
  libdrm,
  libxkbcommon,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libXrender,
  libXi,
  libXcursor,
  libXScrnSaver,
  libXtst,
  pango,
  cairo,
  atk,
  gdk-pixbuf,
  gtk3,
  libnotify,
  libsecret,
  libuuid,
  at-spi2-core,
  xdg-utils,
  wl-clipboard,
}:

stdenv.mkDerivation rec {
  pname = "clash-party";
  version = "2.0.4";

  # 上游 deb 打包。x86_64 只有 amd64 版。
  src = fetchurl {
    url = "https://github.com/mihomo-party-org/clash-party/releases/download/v${version}/clash-party-linux-${version}-amd64.deb";
    hash = "sha256-M/O3WowO2RwJSZwLny4Ot1XlrhP2nW/6urcT+7m786Q=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    nss
    nspr
    alsa-lib
    openssl
    webkitgtk_4_1
    udev
    libayatana-appindicator
    (lib.getLib stdenv.cc.cc)
    libGL
    libgbm
    libdrm
    libxkbcommon
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libXrender
    libXi
    libXcursor
    libXScrnSaver
    libXtst
    pango
    cairo
    atk
    gdk-pixbuf
    gtk3
    libnotify
    libsecret
    libuuid
    at-spi2-core
    xdg-utils
    wl-clipboard
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp -r opt/clash-party $out/opt/clash-party
    cp -r usr/share $out/share

    # deb 内 desktop 文件指向 /opt 路径。改指向 bin。
    substituteInPlace $out/share/applications/mihomo-party.desktop \
      --replace-fail "/opt/clash-party/mihomo-party" "clash-party"

    ln -s $out/opt/clash-party/mihomo-party $out/bin/clash-party

    runHook postInstall
  '';

  meta = with lib; {
    description = "Mihomo GUI client (Clash Party)";
    homepage = "https://clashparty.org";
    license = licenses.gpl3;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "clash-party";
  };
}
