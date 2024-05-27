{
  inputs = {
    hax.url = "github:hacspec/hax";
    eurydice.url = "github:aeneasverif/eurydice";
  };

  outputs =
    inputs:
    let
      system = "x86_64-linux";
    in
    {
      packages.${system} = {
        hax = inputs.hax.packages.${system}.hax;
        eurydice = inputs.eurydice.packages.${system}.default;
      };
      inherit inputs;
    };
}
