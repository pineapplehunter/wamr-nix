{
  asmjit,
  cmake,
  fetchFromGitHub,
  lib,
  libffi,
  libpfm,
  libxml2,
  llvm,
  pkg-config,
  simde,
  stdenv,

  # these are options prefixed with `WAMR_BUILD_...`
  enable_aot ? true,
  enable_debug_interp ? false,
  enable_fast_interp ? true,
  enable_fast_jit ? false,
  enable_interp ? true,
  enable_jit ? false,
  enable_lazy_jit ? false,
  enable_lib_pthread ? false,
  enable_lib_wasi_threads ? false,
  enable_libc_builtin ? true,
  enable_libc_wasi ? true,
  enable_mini_loader ? false,
  enable_multi_module ? false,
  enable_ref_types ? true,
  enable_simd ? !stdenv.hostPlatform.isStatic, # simde is not building with musl
  enable_wasi_nn ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wamr";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "bytecodealliance";
    repo = "wasm-micro-runtime";
    tag = "WAMR-${finalAttrs.version}";
    hash = "sha256-jrJ9aO/nc6TEUjehMm0deBtCXpx22YBSKyEB/Dzbc3c=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ] ++ lib.optionals enable_simd [ pkg-config ];

  buildInputs =
    lib.optionals enable_jit [
      libffi
      libxml2
      llvm
    ]
    ++ lib.optionals (enable_jit && stdenv.hostPlatform.isLinux) [
      libpfm
    ]
    ++ lib.optionals enable_fast_jit [
      asmjit
    ]
    ++ lib.optionals (enable_simd && !stdenv.hostPlatform.isStatic) [
      simde
    ];

  cmakeFlags =
    let
      cmakeBoolInt = property: value: lib.cmakeFeature property (if value then "1" else "0");
    in
    [
      (cmakeBoolInt "WAMR_BUILD_AOT" enable_aot)
      (cmakeBoolInt "WAMR_BUILD_DEBUG_INTERP" enable_debug_interp)
      (cmakeBoolInt "WAMR_BUILD_FAST_INTERP" enable_fast_interp)
      (cmakeBoolInt "WAMR_BUILD_FAST_JIT" enable_fast_jit)
      (cmakeBoolInt "WAMR_BUILD_INTERP" enable_interp)
      (cmakeBoolInt "WAMR_BUILD_JIT" enable_jit)
      (cmakeBoolInt "WAMR_BUILD_LAZY_JIT" enable_lazy_jit)
      (cmakeBoolInt "WAMR_BUILD_LIBC_BUILTIN" enable_libc_builtin)
      (cmakeBoolInt "WAMR_BUILD_LIBC_WASI" enable_libc_wasi)
      (cmakeBoolInt "WAMR_BUILD_LIB_PTHREAD" enable_lib_pthread)
      (cmakeBoolInt "WAMR_BUILD_LIB_WASI_THREADS" enable_lib_wasi_threads)
      (cmakeBoolInt "WAMR_BUILD_MINI_LOADER" enable_mini_loader)
      (cmakeBoolInt "WAMR_BUILD_MULTI_MODULE" enable_multi_module)
      (cmakeBoolInt "WAMR_BUILD_REF_TYPES" enable_ref_types)
      (cmakeBoolInt "WAMR_BUILD_SIMD" enable_simd)
      (cmakeBoolInt "WAMR_BUILD_WASI_NN" enable_wasi_nn)
    ]
    ++ lib.optionals enable_jit [ (lib.cmakeFeature "LLVM_DIR" "${llvm.dev}") ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      (lib.cmakeFeature "CMAKE_OSX_DEPLOYMENT_TARGET" "${stdenv.hostPlatform.darwinSdkVersion}")
    ];

  postPatch =
    ''
      # patches
      ln -sf ${./iwasm_fast_jit_patch.cmake} core/iwasm/fast-jit/iwasm_fast_jit.cmake
      ln -sf ${./simde_patch.cmake} core/iwasm/libraries/simde/simde.cmake
    ''
    + (
      if stdenv.hostPlatform.isLinux then
        ''
          cd product-mini/platforms/linux
        ''
      else if stdenv.hostPlatform.isDarwin then
        ''
          cd product-mini/platforms/darwin
        ''
      else
        throw "unsupported platform"
    );

  meta = with lib; {
    description = "WebAssembly Micro Runtime";
    homepage = "https://github.com/bytecodealliance/wasm-micro-runtime";
    license = licenses.asl20;
    mainProgram = "iwasm";
    maintainers = with maintainers; [ ereslibre ];
    platforms = platforms.unix;
  };
})
