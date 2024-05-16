{
  inputs = {
    hax.url = "github:hacspec/hax";
    charon.url = "github:aeneasverif/charon";
    aeneas = {
      url = "github:aeneasverif/aeneas";
      inputs.charon.follows = "charon";
    };
    eurydice = {
      url = "github:aeneasverif/eurydice";
      inputs.charon.follows = "charon";
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
        charon = inputs.charon.packages.${system}.charon.override (_: {
          cargoLock = ./charon.lock;
        });
        aeneas = inputs.aeneas.packages.${system}.aeneas;
        eurydice = inputs.eurydice.packages.${system}.default;
      };
      inherit inputs;
    };
}
