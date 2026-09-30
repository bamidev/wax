{
  pkgs,
  lib,
  python,
}:
let
  buildPythonPackage = import ../build.nix { inherit pkgs lib python; };
in
rec {
  cffi = buildPythonPackage {
    pname = "cffi";
    version = "1.15.1";
    hash = "sha256-1AC/uaN7E1ElPLQCZxzqfom97MKU6AFqcH9tHYrJNPk=";
    nativeBuildInputs = [
      setuptools
      pycparser
      pkgs.pkg-config
    ];
    buildInputs = with pkgs; [
      libffi
      libxcrypt-legacy
    ];
    pythonImportsCheck = [ "cffi" ];
  };

  importlib-metadata = buildPythonPackage {
    pname = "importlib_metadata";
    version = "6.7.0";
    hash = "sha256-Gq9VDU9z5dZ4PnrLd67EPUnagBdBCvrpOCLMnMqYxNQ=";
    nativeBuildInputs = [
      packaging
      setuptools
      setuptools-scm
      tomli
      zipp
    ];
  };

  packaging = buildPythonPackage {
    pname = "packaging";
    version = "23.2";
    hash = "sha256-BI+w6UBQNlGOqvSKVZU8dQwR4aG2jg3RqdYu0MCSz8U=";
    nativeBuildInputs = [ setuptools ];
    # Upstream builds with flit_core and reads `version` dynamically from packaging/__about__.py.
    # Our setup.py-less shim just calls `setuptools.setup()` against pyproject.toml directly,
    # which can't resolve a flit-style dynamic version, so pin it explicitly here.
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail \
        'dynamic = ["version"]' 'version = "23.2"'
    '';
    pythonImportsCheck = [ "packaging" ];
  };

  pycparser = buildPythonPackage {
    pname = "pycparser";
    version = "2.21";
    hash = "sha256-5kT97BL3hy+GxY/3kNpFYhixD4Y5cCSVFtYKXqyncgY=";
    nativeBuildInputs = [ setuptools ];
    pythonImportsCheck = [ "pycparser" ];
  };

  semantic-version = buildPythonPackage {
    pname = "semantic_version";
    version = "2.10.0";
    hash = "sha256-vau20zaZjLs3jUuds6S1ah4yNXAdwF6iaQ2amX7VBBw=";
  };

  setuptools = buildPythonPackage {
    pname = "setuptools";
    version = "67.8.0";
    hash = "sha256-YmQjWK3Hf/qHIzvE0jVMSyaC0hQEj1AJZNvnYMzt8QI=";
    pythonImportsCheck = [ "setuptools" ];
  };

  setuptools-scm = buildPythonPackage {
    pname = "setuptools_scm";
    version = "7.1.0";
    hash = "sha256-bFCDRadxqtfVbr/w5wYovysOx1c3Yr6ZYCFHMN4njyc=";
    nativeBuildInputs = [
      setuptools
      packaging
    ];
    pythonImportsCheck = [ "setuptools_scm" ];
  };

  tomli = buildPythonPackage {
    pname = "tomli";
    version = "2.0.1";
    hash = "sha256-3lJsEpFPDFUNFZJMYtcqvEjW/nNkqocygzejEAf+ik8=";
    nativeBuildInputs = [ setuptools ];
    pythonImportsCheck = [ "tomli" ];
  };

  typing-extensions = buildPythonPackage {
    pname = "typing_extensions";
    version = "4.7.1";
    hash = "sha256-t13cJk8LpWFdt7ohfa65lwGtKVNTxF+elZYzN87u/7I=";
    nativeBuildInputs = [ setuptools ];
    pythonImportsCheck = [ "typing_extensions" ];
  };

  setuptools-rust = buildPythonPackage {
    pname = "setuptools-rust";
    version = "1.7.0";
    hash = "sha256-xxAJmZSCNaOK5+VV/hmapmwlPcOEsSX12FRzv4Hq46M=";
    nativeBuildInputs = [
      setuptools
      semantic-version
      typing-extensions
      tomli
    ];
    pythonImportsCheck = [ "setuptools_rust" ];
  };

  zipp = buildPythonPackage {
    pname = "zipp";
    version = "3.15.0";
    hash = "sha256-ESkprWSdqUHCPeUPNWorVXDJVLZRUGQrzN1mvxlNIks=";
    nativeBuildInputs = [
      packaging
      setuptools
      setuptools-scm
      tomli
    ];
  };
}
