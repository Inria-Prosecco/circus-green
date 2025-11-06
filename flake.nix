{
  # The inputs we care about are: hax, charon, eurydice, bertie. We
  # take good care to avoid duplicated inputs to save on evaluation time.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    # Old nixpkgs that supports llvmPackages_15
    nixpkgs_old.url = "github:nixos/nixpkgs/nixos-25.05";
    flake-utils.follows = "fstar/flake-utils";
    karamel.follows = "eurydice/karamel";
    fstar.follows = "eurydice/karamel/fstar";
    rust-overlay.follows = "charon/rust-overlay";
    crane.follows = "charon/crane";
    charon = {
      url = "github:aeneasverif/charon";
      inputs.flake-utils.follows = "flake-utils";
    };
    aeneas = {
      url = "github:aeneasverif/aeneas";
      inputs.nixpkgs.follows = "charon/nixpkgs";
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
      inputs.flake-utils.follows = "flake-utils";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.crane.follows = "crane";
    };
    bertie = {
      url = "github:cryspen/bertie";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.crane.follows = "crane";
      inputs.hax.follows = "hax";
    };
    scylla = {
      url = "github:aeneasverif/scylla";
      inputs.nixpkgs.follows = "nixpkgs_old";
      inputs.flake-utils.follows = "flake-utils";
      inputs.karamel.follows = "karamel";
    };
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: rec {
      packages = {
        hax = inputs.hax.packages.${system}.hax;
        charon = inputs.charon.packages.${system}.default;
        aeneas = inputs.aeneas.packages.${system}.default;
        eurydice = inputs.eurydice.packages.${system}.default;
        scylla = inputs.scylla.devShells.${system}.default;
        bertie = inputs.bertie.packages.${system}.default ./bertie-Cargo.lock;
        inherit inputs;
      };
      checks = {
        hax = inputs.hax.checks.${system}.toolchain;
        charon = inputs.charon.checks.${system}.charon-ml-tests;
        aeneas = inputs.aeneas.checks.${system}.default;
        eurydice = inputs.eurydice.checks.${system}.default;
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
