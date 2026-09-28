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
  cbor2 = pythonPackage {
    pname = "cbor2";
    version = "5.4.2.post1";
    hash = "sha256-nPIdWWBLlSnXh3yOA0Ki66rhoH/o/1aD3HX+wVhHx5c=";
    nativeBuildInputs = [ pythonDefaultPackages.setuptools-scm ];
  };

  gevent = pythonPackage {
    pname = "gevent";
    version = "21.8.0";
    hash = "sha256-Q+k+Gkc4ySKiQWuvM/CvsKILItPbqIZyC8A3zQKphXU=";
  };

  # Wraps libmagic via ctypes.CDLL('libmagic.so.1'), an eager dlopen() at import time. There's no
  # traditional ldconfig cache in the nix sandbox, so this only resolves via LD_LIBRARY_PATH -
  # which the odoo 19 shellHook sets up, but the isolated build sandbox doesn't. That's why
  # pythonImportsCheck is omitted here unlike every other package in this file.
  python-magic = pythonPackage {
    pname = "python-magic";
    version = "0.4.24";
    hash = "sha256-3oAN+ftQ+OxZdHYQVKcIr25CRrA7S9rumT+UiUew688=";
  };
}
