{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  meson,
  ninja,
}:

stdenv.mkDerivation rec {
  pname = "zycore";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "zyantific";
    repo = "zycore-c";
    rev = "v${version}";
    hash = "sha256-2HJo62+6bpPassJqZwp2CqFVM2YTC1wha9mJwDHm9+s=";
  };

  nativeBuildInputs = [
    cmake
    meson
    ninja
  ];

  meta = {
    description = "Internal library providing platform independent types, macros and a fallback for environments without LibC";
    homepage = "https://github.com/zyantific/zycore-c.git\n";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "zycore-c";
    platforms = lib.platforms.all;
  };
}
