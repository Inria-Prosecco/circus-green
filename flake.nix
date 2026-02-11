{
  # The inputs we care about are: charon, eurydice, bertie. We
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
    bertie = {
      url = "github:cryspen/bertie";
      flake = false;
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
        charon = inputs.charon.packages.${system}.default;
        aeneas = inputs.aeneas.packages.${system}.default;
        eurydice = inputs.eurydice.packages.${system}.default;
        scylla = inputs.scylla.devShells.${system}.default;
        bertie =
          let
            pkgs = import inputs.nixpkgs { inherit system; };
            bertie_llbc = inputs.charon.extractCrateWithCharon.${system} {
              name = "bertie";
              src = pkgs.runCommand "bertie-src" { } ''
                cp -r ${inputs.bertie} $out
                chmod u+w $out
                rm -f $out/Cargo.lock
                cp ${./bertie-Cargo.lock} $out/Cargo.lock
              '';
              charonArgs = "--preset=aeneas";
              cargoArgs = "-p bertie";
            };
          in
          bertie_llbc;
        inherit inputs;
      };
      checks = {
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
