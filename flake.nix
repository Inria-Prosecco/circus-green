{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    charon = {
      url = "github:aeneasverif/charon";
      inputs.nixpkgs.follows = "eurydice/nixpkgs";
    };
    eurydice = {
      url = "github:aeneasverif/eurydice";
      inputs.charon.follows = "charon";
    };
    hax.url = "github:hacspec/hax";
    libcrux = {
      url = "github:cryspen/libcrux/dev";
      flake = false;
    };
    bertie = {
      url = "github:cryspen/bertie";
      flake = false;
    };
    crane.follows = "charon/crane";
    rust-overlay.follows = "charon/rust-overlay";
    fstar.url = "github:fstarlang/fstar";
    karamel.url = "github:fstarlang/karamel";
  };

  outputs =
    inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ (import inputs.rust-overlay) ];
      };
      craneLib = inputs.crane.mkLib pkgs;
    in
    {
      packages.${system} = {
        hax = inputs.hax.packages.${system}.hax;
        charon = inputs.charon.packages.${system}.default;
        eurydice = inputs.eurydice.packages.${system}.default;
        ml-kem =
          let
            cargoLock = ./libcrux.lock;
            src = "${inputs.libcrux}";
            cargoArtifacts = craneLib.buildDepsOnly { inherit src cargoLock; };
          in
          craneLib.buildPackage {
            inherit src cargoLock cargoArtifacts;
            name = "ml-kem";
            buildPhase = "cd libcrux-ml-kem && bash c.sh";
            CHARON_HOME = inputs.charon.packages.${system}.default;
            EURYDICE_HOME =
              pkgs.runCommand "eurydice" { }
                "cp -r ${inputs.eurydice.packages.${system}.default}/bin $out";
            FSTAR_HOME = inputs.fstar.packages.${system}.default;
            KRML_HOME = inputs.karamel.packages.${system}.default.home;
          };
        bertie =
          let
            cargoLock = ./bertie.lock;
            src = "${inputs.bertie}";
            cargoArtifacts = craneLib.buildDepsOnly { inherit src cargoLock; };
          in
          craneLib.buildPackage {
            inherit src cargoLock cargoArtifacts;
            buildInputs = [
              pkgs.python3
              inputs.hax.packages.${system}.hax
            ];
            buildPhase = "python hax-driver.py extract-fstar";
            installPhase = "cp -r . $out";
            doCheck = false;
          };
      };
      inherit inputs;
    };
}
