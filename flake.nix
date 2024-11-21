{
  # The inputs we care about are: hax, charon, eurydice, libcrux, bertie. We
  # take good care to avoid duplicated inputs to save on evaluation time.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.follows = "fstar/flake-utils";
    crane.url = "github:ipetkov/crane";
    fstar.follows = "eurydice/fstar";
    karamel.follows = "eurydice/karamel";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    charon = {
      url = "github:aeneasverif/charon";
      inputs.nixpkgs.follows = "eurydice/nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.crane.follows = "crane";
    };
    eurydice = {
      url = "github:aeneasverif/eurydice";
      # If we override this, we would need to override karamel's nixpkgs too to
      # get compatible ocaml versions, but flakes don't support nested
      # overrides. We also can't use eurydice's nixpkgs everywhere because it
      # does not contain `mold-wrapped` which is required by libcrux.
      # inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.charon.follows = "charon";
    };
    hax = {
      url = "github:hacspec/hax";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.fstar.follows = "fstar";
      inputs.crane.follows = "crane";
    };
    libcrux = {
      url = "github:cryspen/libcrux";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.crane.follows = "crane";
      inputs.charon.follows = "charon";
      inputs.eurydice.follows = "eurydice";
      inputs.fstar.follows = "fstar";
      inputs.karamel.follows = "karamel";
      inputs.hax.follows = "hax";
    };
    bertie = {
      url = "github:cryspen/bertie";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.crane.follows = "crane";
      inputs.hax.follows = "hax";
    };
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: rec {
      packages = {
        hax = inputs.hax.packages.${system}.hax;
        charon = inputs.charon.packages.${system}.default;
        eurydice = inputs.eurydice.packages.${system}.default;
        ml-kem = inputs.libcrux.packages.${system}.ml-kem.override {
          cargoLock = ./libcrux-Cargo.lock;
        };
        bertie = inputs.bertie.packages.${system}.default;
        inherit inputs;
      };
      checks = rec {
        hax = inputs.hax.checks.${system}.toolchain;
        charon = inputs.charon.checks.${system}.charon-ml-tests;
        eurydice = inputs.eurydice.checks.${system}.default;
        ml-kem = packages.ml-kem;
        ml-kem-small = ml-kem.override {
          checkHax = false;
          runBenchmarks = false;
        };
        bertie = packages.bertie;
      };
    });
}
