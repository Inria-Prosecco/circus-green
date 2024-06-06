{
  inputs = {
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
      url = "github:cryspen/libcrux";
      inputs.charon.follows = "charon";
      inputs.eurydice.follows = "eurydice";
      inputs.fstar.follows = "eurydice/fstar";
      inputs.karamel.follows = "eurydice/karamel";
      inputs.hax.follows = "hax";
    };
    bertie = {
      url = "github:cryspen/bertie";
      inputs.hax.follows = "hax";
    };
  };

  outputs =
    inputs:
    let
      system = "x86_64-linux";
    in
    {
      packages.${system} = {
        hax = inputs.hax.packages.${system}.hax;
        charon = inputs.charon.packages.${system}.default;
        eurydice = inputs.eurydice.packages.${system}.default;
        ml-kem = inputs.libcrux.packages.${system}.ml-kem;
        bertie = inputs.bertie.packages.${system}.default;
        inherit inputs;
      };
    };
}
