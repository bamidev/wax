{
  description = "Wax CI example";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    wax.url = "github:bamidev/wax";
  };

  outputs = { self, flake-utils, wax }:
    flake-utils.lib.eachDefaultSystem (system:
      {
        devShells.default = wax.lib.mkOdooShell {
          system = system;
          config = import ./config.nix;
        };
    });
}
