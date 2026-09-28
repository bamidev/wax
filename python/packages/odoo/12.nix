{
  config,
  pkgs,
  lib,
  python,
  pythonDefaultPackages,
}:
let
  pythonPackage = python.pythonPackage pythonDefaultPackages;
  common = import ./common/${lib.versions.majorMinor python.version}.nix {
    inherit
      config
      pkgs
      lib
      python
      pythonDefaultPackages
      ;
  };
in
common
// rec {
  libsass = pythonPackage {
    pname = "libsass";
    version = "0.12.3";
    hash = "sha256-I2dir5xpO7cu2S1l/0pad9J6+UlLYXT77H5jCEFmc7A=";
  };

  python-stdnum = pythonPackage {
    pname = "python-stdnum";
    version = "1.8";
    hash = "sha256-P0JjnK51wPa6c06qc5HUEbf974aIc1A/fSspYvw9cb0=";
  };
}
