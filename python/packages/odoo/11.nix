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
// {
  feedparser = pythonPackage {
    pname = "feedparser";
    version = "5.2.1";
    hash = "sha256-vQMGUsLQhTLANMJ/zXyFho5/o8srF/IwpEprvJJRm/k=";
  };

  phonenumbers = pythonPackage {
    pname = "phonenumbers";
    version = "9.0.7";
    hash = "sha256-1Mwqo2y/mwAEw3D0BtFRDd71a7qeX3WUce9H6ZjYovk=";
  };

  pyyaml = pythonPackage {
    pname = "PyYAML";
    version = "3.12";
    hash = "sha256-WSdmxjAyB6IO/ERVh3eDItf3OxYb2ZTyJ62qNBuiEqs=";
    pythonImportsCheck = [ "yaml" ];
  };

  python-stdnum = pythonPackage {
    pname = "python-stdnum";
    version = "1.14";
    hash = "sha256-/TqSuOyCoVnEHbqjxTl5NNCQCQySsE40ZBLg/X5qGxw=";
  };

  vatnumber = pythonPackage {
    pname = "vatnumber";
    version = "1.0";
    hash = "sha256-bvYQP37PCc3zK4e7HIdha3K5VG5LNko7ZtKwtLNAZlo=";
  };
}
