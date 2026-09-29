{
  pkgs,
  lib,
  python,
  buildPythonPackage,
}:
if lib.versionOlder python.version "3.10" then
  null
else
  buildPythonPackage {
    pname = "poetry_core";
    version = "2.5.0";
    hash = "sha256-gdBMklOxnQYEcYJo14GGfI97ISjlslu/HoQUHuxricQ=";
    buildBackend = "poetry";
    # PEP 517's `backend-path = ["src"]` normally tells the build frontend to import the backend
    # straight from the source tree being built rather than a separately-installed copy, avoiding
    # the bootstrap problem of poetry-core needing poetry-core to build. We don't implement
    # backend-path generically, so just prepend the same path ourselves.
    preBuild = ''
      export PYTHONPATH="$(pwd)/src:$PYTHONPATH"
    '';
    pythonImportsCheck = [ "poetry.core.masonry.api" ];
  }
