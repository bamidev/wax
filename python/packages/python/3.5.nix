# Nothing in odoo 11/12's own requirements needs cffi/rust bindings (no cryptography, no other
# cffi-based deps), so unlike the 3.6/3.7 toolchains this stays minimal: just enough for packages
# that version themselves via setuptools_scm to build.
{
  pkgs,
  lib,
  python,
}:
let
  buildPythonPackage = import ../build.nix { inherit pkgs lib python; };
in
rec {
  setuptools = buildPythonPackage {
    pname = "setuptools";
    version = "50.3.2";
    extension = "zip";
    hash = "sha256-7QUZ0nokOEOwXYKl6dAbCwg9mTTqo9AneaI9oYB3vTw=";
    nativeBuildInputs = [ pkgs.unzip ];
    pythonImportsCheck = [ "setuptools" ];
  };

  # 5.0.2's install_requires is just "setuptools" - unlike the 6.x/7.x used for 3.6/3.7, it
  # doesn't need packaging or tomli (toml support here is an optional, unused extra).
  setuptools-scm = buildPythonPackage {
    pname = "setuptools_scm";
    version = "5.0.2";
    hash = "sha256-g6DO3TRJ45RjB4EaTHudicS1/UZKL7XuzNCluxWK5cg=";
    nativeBuildInputs = [ setuptools ];
    pythonImportsCheck = [ "setuptools_scm" ];
  };
}
