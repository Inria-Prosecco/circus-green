{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
    charon = {
      url = "github:aeneasverif/charon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    eurydice = {
      url = "github:aeneasverif/eurydice";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.charon.follows = "charon";
    };
    fstar.follows = "eurydice/fstar";
    karamel.follows = "eurydice/karamel";
    hax = {
      url = "github:hacspec/hax";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fstar.follows = "fstar";
    };
    libcrux = {
      url = "github:cryspen/libcrux";
      inputs.charon.follows = "charon";
      inputs.eurydice.follows = "eurydice";
      inputs.fstar.follows = "fstar";
      inputs.karamel.follows = "karamel";
      inputs.hax.follows = "hax";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bertie = {
      url = "github:cryspen/bertie";
      inputs.hax.follows = "hax";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: {
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
    });
}
