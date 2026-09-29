# Nothing in odoo 8/9/10's requirements uses PEP 517 build backends or setuptools_scm-based
# versioning (this predates all of that), so this stays as minimal as it can: just setuptools.
{
  pkgs,
  lib,
  python,
}:
let
  buildPythonPackage = import ../build-python-package.nix { inherit pkgs lib python; };
in
rec {
  setuptools = buildPythonPackage {
    pname = "setuptools";
    version = "44.1.1";
    extension = "zip";
    hash = "sha256-xnqlXbUyoNrcTS4guplhy9PMyE1UTpApaZgiVCtaR2s=";
    nativeBuildInputs = [ pkgs.unzip ];
    pythonImportsCheck = [ "setuptools" ];
  };
}
