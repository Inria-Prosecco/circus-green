{
  # The inputs we care about are: hax, charon, eurydice, libcrux, bertie. We
  # take good care to avoid duplicated inputs to save on evaluation time.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.follows = "fstar/flake-utils";
    crane.url = "github:ipetkov/crane/da87d1af7e4e09fd0271432340a5cadf3eb96005";
    karamel.follows = "eurydice/karamel";
    karamel.inputs.nixpkgs.follows = "nixpkgs";
    fstar.url = "github:FStarLang/fstar";
    fstar.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.follows = "charon/rust-overlay";
    charon = {
      url = "github:aeneasverif/charon";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-ocaml.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.crane.follows = "crane";
    };
    aeneas = {
      url = "github:aeneasverif/aeneas";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.charon.follows = "charon";
      inputs.fstar.follows = "fstar";
    };
    eurydice = {
      url = "github:aeneasverif/eurydice";
      inputs.nixpkgs.follows = "nixpkgs";
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
        aeneas = inputs.aeneas.packages.${system}.default;
        eurydice = inputs.eurydice.packages.${system}.default;
        ml-kem = inputs.libcrux.packages.${system}.ml-kem.override {
          cargoLock = ./libcrux-Cargo.lock;
        };
        bertie = inputs.bertie.packages.${system}.default ./bertie-Cargo.lock;
        inherit inputs;
      };
      checks = rec {
        hax = inputs.hax.checks.${system}.toolchain;
        charon = inputs.charon.checks.${system}.charon-ml-tests;
        aeneas = inputs.aeneas.checks.${system}.default;
        eurydice = inputs.eurydice.checks.${system}.default;
        ml-kem = packages.ml-kem;
        ml-kem-small = ml-kem.override {
          checkHax = false;
          runBenchmarks = false;
        };
        bertie = packages.bertie;
      };
      # Make a dev-shell with an appropriate rust toolchain, used to regenerate
      # the `Cargo.lock`s.
      devShells.default =
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          rustToolchain = inputs.charon.packages.${system}.rustToolchain;
          craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rustToolchain;
        in
        craneLib.devShell {
          packages = [ pkgs.jq ];
        };
    });
}
