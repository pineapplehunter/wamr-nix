{
  description = "A basic package";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  inputs.systems.url = "github:nix-systems/default";

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      eachSystem =
        f:
        lib.genAttrs (import inputs.systems) (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            }
          )
        );
    in
    {
      overlays.default =
        final: _:
        lib.packagesFromDirectoryRecursive {
          inherit (final) callPackage;
          directory = ./pkgs;
        };

      packages = eachSystem (pkgs: {
        default = pkgs.wamr;
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
        wamr-fast-jit = pkgs.wamr.override {
          enable_interp = false;
          enable_fast_interp = false;
          enable_aot = false;
          enable_jit = true;
          enable_fast_jit = true;
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
        wamr-static-jit = pkgs.pkgsStatic.wamr.override {
          enable_interp = false;
          enable_fast_interp = false;
          enable_aot = false;
          enable_jit = true;
          enable_fast_jit = false;
          enable_lazy_jit = false;
        };
      });

      checks = eachSystem (pkgs: self.packages.${pkgs.system});

      legacyPackages = eachSystem lib.id;
    };
}
