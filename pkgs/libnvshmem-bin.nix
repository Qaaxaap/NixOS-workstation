{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation rec {
  pname = "libnvshmem";
  version = "3.6.5";

  # NVIDIA 官方二进制归档。nixpkgs 的同名包需要源码编译。
  # torch 的 libtorch_cuda.so 在 NEEDED 里引用了 libnvshmem_host.so.3。
  src = fetchurl {
    url = "https://developer.download.nvidia.com/compute/nvshmem/redist/libnvshmem/linux-x86_64/libnvshmem-linux-x86_64-${version}_cuda12-archive.tar.xz";
    hash = "sha256-lZBIqJAASP15p/kdI8zpaVswMJ5qXcs5RN3PFsZrZD0=";
  };

  sourceRoot = "libnvshmem-linux-x86_64-${version}_cuda12-archive";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  # 只装 host 运行库与头文件。bootstrap/transport 插件与 device bitcode 不需要。
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -a lib/libnvshmem_host.so lib/libnvshmem_host.so.3 lib/libnvshmem_host.so.3.6.5 $out/lib/

    if [ -d include ]; then
      cp -a include $out/
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "NVSHMEM host runtime from the official NVIDIA archive";
    homepage = "https://developer.nvidia.com/nvshmem";
    license = licenses.unfree;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
