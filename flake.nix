{
  inputs = {
    hax.url = "github:hacspec/hax";
    charon.url = "github:aeneasverif/charon";
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
      };
      inherit inputs;
    };
}
