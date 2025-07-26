{
  description = "A basic package";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "riscv64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      overlays = [ self.overlays.default ];
      eachSystem = f: lib.genAttrs systems (system: f (import nixpkgs { inherit system overlays; }));
    in
    {
      overlays.default =
        final: _:
        lib.packagesFromDirectoryRecursive {
          inherit (final) callPackage;
          directory = ./pkgs;
        };

      packages = eachSystem (
        pkgs:
        {
          default = pkgs.wamr;
          inherit (pkgs) wamr wamrc;
          wamr-classic = pkgs.wamr.override {
            enable_interp = true;
            enable_fast_interp = false;
            enable_aot = false;
            enable_jit = false;
            enable_fast_jit = false;
            enable_lazy_jit = false;
          };
          wamr-fast-interp = pkgs.wamr.override {
            enable_interp = true;
            enable_fast_interp = true;
            enable_aot = false;
            enable_jit = false;
            enable_fast_jit = false;
            enable_lazy_jit = false;
          };
          wamr-aot = pkgs.wamr.override {
            enable_interp = false;
            enable_fast_interp = false;
            enable_aot = true;
            enable_jit = false;
            enable_fast_jit = false;
            enable_lazy_jit = false;
          };
          wamr-jit = pkgs.wamr.override {
            enable_interp = false;
            enable_fast_interp = false;
            enable_aot = false;
            enable_jit = true;
            enable_fast_jit = false;
            enable_lazy_jit = false;
          };
          wamr-lazy-jit = pkgs.wamr.override {
            enable_interp = false;
            enable_fast_interp = false;
            enable_aot = false;
            enable_jit = true;
            enable_fast_jit = false;
            enable_lazy_jit = true;
          };
          wamr-static = pkgs.pkgsStatic.wamr;
        }
        // lib.optionalAttrs (pkgs.hostPlatform.system == "x86_64-linux") {
          wamr-fast-jit = pkgs.wamr.override {
            enable_interp = false;
            enable_fast_interp = false;
            enable_aot = false;
            enable_jit = true;
            enable_fast_jit = true;
            enable_lazy_jit = false;
          };
        }
      );

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            cmake
            wamr
          ];
        };
      });

      checks = eachSystem (
        pkgs:
        self.packages.${pkgs.system}
        // {
          wamr_enable_aot = pkgs.wamr.override { enable_aot = true; };
          wamr_enable_debug_interp = pkgs.wamr.override { enable_debug_interp = true; };
          wamr_enable_fast_interp = pkgs.wamr.override { enable_fast_interp = true; };
          wamr_enable_interp = pkgs.wamr.override { enable_interp = true; };
          wamr_enable_jit = pkgs.wamr.override { enable_jit = true; };
          wamr_enable_lazy_jit = pkgs.wamr.override { enable_lazy_jit = true; };
          wamr_enable_lib_pthread = pkgs.wamr.override { enable_lib_pthread = true; };
          wamr_enable_lib_wasi_threads = pkgs.wamr.override { enable_lib_wasi_threads = true; };
          wamr_enable_libc_builtin = pkgs.wamr.override { enable_libc_builtin = true; };
          wamr_enable_libc_wasi = pkgs.wamr.override { enable_libc_wasi = true; };
          wamr_enable_mini_loader = pkgs.wamr.override { enable_mini_loader = true; };
          wamr_enable_multi_module = pkgs.wamr.override { enable_multi_module = true; };
          wamr_enable_ref_types = pkgs.wamr.override { enable_ref_types = true; };
          wamr_enable_simd = pkgs.wamr.override { enable_simd = true; };
        }
        // lib.optionalAttrs (pkgs.system == "x86_64-linux") {
          wamr_enable_fast_jit = pkgs.wamr.override { enable_fast_jit = true; };
        }
      );

      legacyPackages = eachSystem lib.id;
    };
}
