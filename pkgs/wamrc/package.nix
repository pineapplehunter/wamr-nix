{
  wamr,
  stdenv,
  cmake,
  llvm,
  lib,
}:
stdenv.mkDerivation {
  pname = "wamrc";
  inherit (wamr) version src;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ llvm ];

  cmakeFlags = [ (lib.cmakeBool "WAMR_BUILD_WITH_CUSTOM_LLVM" true) ];

  postPatch = ''
    cd wamr-compiler
  '';

  meta.mainProgram = "wamrc";
}
