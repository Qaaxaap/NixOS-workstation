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

  # TUN 需要 setuid root 的内核。store 是 ro,nosuid，所以内核放 share，
  # resources/sidecar 指向 security.wrappers 生成的 setuid 包装器。
  postFixup = ''
    mkdir -p $out/share/clash-party
    mv $out/opt/clash-party/resources/sidecar $out/share/clash-party/sidecar

    mkdir -p $out/opt/clash-party/resources/sidecar
    ln -s /run/wrappers/bin/clash-party-mihomo $out/opt/clash-party/resources/sidecar/mihomo
    ln -s /run/wrappers/bin/clash-party-mihomo-alpha $out/opt/clash-party/resources/sidecar/mihomo-alpha
    ln -s /run/wrappers/bin/clash-party-mihomo-smart $out/opt/clash-party/resources/sidecar/mihomo-smart
    ln -s $out/share/clash-party/sidecar/sysproxy.linux-x64-gnu.node $out/opt/clash-party/resources/sidecar/sysproxy.linux-x64-gnu.node
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
