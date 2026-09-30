# Same toolchain shape as 3.10.nix/3.11.nix - setuptools 84.0.0 still fully supports PEP 621
# (added at 61), so the same package versions/fixes carry over unchanged. Since it's newer than
# 82, pkg_resources is gone; revisit if a package here still needs it the way cbor2 5.4.2 did on
# 3.7/3.10.
{
  pkgs,
  lib,
  python,
}:
let
  buildPythonPackage = import ../build.nix { inherit pkgs lib python; };
  common310 = import ./3.10.nix { inherit pkgs lib python; };
in
rec {
  cffi = buildPythonPackage {
    pname = "cffi";
    version = "2.1.1";
    hash = "sha256-3TH1LqEIZRO7nfMPj87puJGDI64Gej1beLyCagAHEr4=";
    dependencies = [
      setuptools
      pycparser
    ];
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = with pkgs; [
      libffi
      libxcrypt-legacy
    ];
    pythonImportsCheck = [ "cffi" ];
  };

  # zipp's own closure already covers setuptools/packaging/setuptools-scm/tomli - see zipp below.
  importlib-metadata = buildPythonPackage {
    pname = "importlib_metadata";
    version = "9.0.1";
    hash = "sha256-q4MFgLwO89thzo+ucWOJ5UYrZ+AzAYurbY+A7xcXL5k=";
    dependencies = [ zipp ];
    # Ships no setup.py, only a dynamic [project] table (jaraco/skeleton's usual
    # coherent.licensed/setuptools_scm-driven build, irrelevant to us since our setup.py-less
    # fallback never invokes the declared backend at all - it just reads the [project] table
    # directly). Only `version` is dynamic, so pinning just that (same technique as `packaging`
    # elsewhere) is enough.
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail \
        'dynamic = ["version"]' 'version = "9.0.1"'
    '';
    pythonImportsCheck = [ "importlib_metadata" ];
  };

  inherit (common310) packaging;
  inherit (common310) hatchling;
  inherit (common310) pathspec;
  inherit (common310) pluggy;
  inherit (common310) tomlkit;
  inherit (common310) trove-classifiers;

  pycparser = buildPythonPackage {
    pname = "pycparser";
    version = "3.0";
    hash = "sha256-YA9J0hcwSlkCrDw34Sgcn+lOTQSJ3mQ6lQTFzf38ayk=";
    dependencies = [ setuptools ];
    pythonImportsCheck = [ "pycparser" ];
  };

  semantic-version = buildPythonPackage {
    pname = "semantic_version";
    version = "2.10.0";
    hash = "sha256-vau20zaZjLs3jUuds6S1ah4yNXAdwF6iaQ2amX7VBBw=";
    dependencies = [ setuptools ];
  };

  setuptools = buildPythonPackage {
    pname = "setuptools";
    version = "84.0.0";
    hash = "sha256-9GlcISV/DZtTfsJpLJQdAu4UO3zBJ2lBNJpUZXOy73M=";
    pythonImportsCheck = [ "setuptools" ];
  };

  # setuptools_scm's own dynamic versioning is self-referential (it versions itself via
  # [tool.setuptools_scm] in its own pyproject.toml), which is exactly why 9.x+ split the real
  # version-detection logic out into this separate package - so that self-reference can be
  # resolved without needing a working setuptools_scm already installed. Real setup.py, plain
  # setuptools.build_meta backend.
  vcs-versioning = buildPythonPackage {
    pname = "vcs-versioning";
    version = "2.5.0";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/6f/a0/6977bb418312ad30f27e522c5040604d4bbf7e40ccd5a11d333afe549354/vcs_versioning-2.5.0.tar.gz";
      hash = "sha256-lWp5bjH4D+cU0hnW0d8Vpr8kfRD22FG/S5gnnQpC2lU=";
    };
    dependencies = [
      packaging
      setuptools
      tomli
      typing-extensions
    ];
    pythonImportsCheck = [ "vcs_versioning" ];
  };

  setuptools-scm = buildPythonPackage {
    pname = "setuptools_scm";
    version = "10.3.4";
    hash = "sha256-pp8ov8JFYIeBIF6RL6rkN8KyFldzr6TnuXnXdEemndI=";
    buildBackend = "wheel";
    dependencies = [ vcs-versioning ];
    pythonImportsCheck = [ "setuptools_scm" ];
  };

  inherit (common310) tomli;

  typing-extensions = buildPythonPackage {
    pname = "typing_extensions";
    version = "4.16.0";
    hash = "sha256-3Jg9GaUJyU26ci7mq9M5QPfAWoniQ8R+kH60228aQ+U=";
    dependencies = [ setuptools ];
    pythonImportsCheck = [ "typing_extensions" ];
  };

  # fetchPypi's legacy "/packages/source/<letter>/<pname>/..." URL 404s for this release (PyPI
  # retired that path for newer uploads); fetch from the real hash-bucketed URL instead.
  setuptools-rust = buildPythonPackage {
    pname = "setuptools-rust";
    version = "1.13.0";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/68/ba/b31781d61bf9ee3c232a1d1160db11c11cdeae1d44e06c90723b25a8279f/setuptools_rust-1.13.0.tar.gz";
      hash = "sha256-8q/PS67uaJkQzknPqKrU4IzOcvQXRJvMMokbhmT9xyY=";
    };
    dependencies = [
      setuptools
      semantic-version
      typing-extensions
      tomli
    ];
    pythonImportsCheck = [ "setuptools_rust" ];
  };

  # setuptools-scm's own closure already covers vcs-versioning/packaging/setuptools/tomli.
  zipp = buildPythonPackage {
    pname = "zipp";
    version = "4.1.0";
    hash = "sha256-TLVzgfVEMV23aI6XbpIqKxjNtRPSHMGU60IjK6Kj5gI=";
    dependencies = [ setuptools-scm ];
    # Same jaraco/skeleton pattern as importlib-metadata above: dynamic version only, irrelevant
    # declared backend since we bypass it entirely.
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail \
        'dynamic = ["version"]' 'version = "4.1.0"'
    '';
  };
}
