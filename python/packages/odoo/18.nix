# 18's requirements happen to be byte-for-byte identical to 17's, so there's nothing
# version-specific to add here - see common/3.10.nix for the actual package set.
{
  config,
  pkgs,
  lib,
  python,
  pythonDefaultPackages,
}:
import ./common/${lib.versions.majorMinor python.version}.nix {
  inherit
    config
    pkgs
    lib
    python
    pythonDefaultPackages
    ;
}
