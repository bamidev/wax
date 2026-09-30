# Same toolchain shape as 3.7.nix - setuptools 81.0.0 still fully supports PEP 621 (added at 61)
# and still ships pkg_resources (removed at 82, which is exactly why python/default.nix pins 81.0.0
# for this python range), so the same package versions/fixes carry over unchanged.
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
    version = "6.7.0";
    hash = "sha256-Gq9VDU9z5dZ4PnrLd67EPUnagBdBCvrpOCLMnMqYxNQ=";
    dependencies = [ zipp ];
  };

  packaging = buildPythonPackage {
    pname = "packaging";
    version = "26.3";
    hash = "sha256-lO3CVkJK84di6zEwbu0ovrnw78UKiDdJLJ1v1gBK7Xk=";
    dependencies = [ setuptools ];
    # setuptools' own PEP 639 license-field handling needs packaging>=24.2 (for packaging.licenses)
    # to build ANY package whose pyproject.toml has a plain `license = "..."` string - not just
    # packages that declare packaging as their own dependency.
    #
    # Upstream builds with flit_core and reads `version` dynamically from packaging/__about__.py.
    # Our setup.py-less shim just calls `setuptools.setup()` against pyproject.toml directly,
    # which can't resolve a flit-style dynamic version, so pin it explicitly here.
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail \
        'dynamic = ["version"]' 'version = "26.3"'
    '';
    pythonImportsCheck = [ "packaging" ];
  };

  # Real backend is hatchling.ouroboros (its own self-hosting bootstrap module), but its
  # [project] table needs nothing more than the usual dynamic-version pin, so the classic bypass
  # path (same as every other hatchling-backed package here) works without needing to actually
  # invoke hatchling's own code to build itself.
  hatchling = buildPythonPackage {
    pname = "hatchling";
    version = "1.32.4";
    hash = "sha256-xEaPcxRMBU0qq07w8DeMQ7mHi/B/j/1reWkOlw03Xwc=";
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail \
        'dynamic = ["version"]' 'version = "1.32.4"'
    '';
    dependencies = [
      setuptools
      packaging
      pathspec
      pluggy
      tomli
      tomlkit
      trove-classifiers
    ];
    pythonImportsCheck = [ "hatchling" ];
  };

  pathspec = buildPythonPackage {
    pname = "pathspec";
    version = "1.1.1";
    hash = "sha256-F9tezVJBBKEg4XOBTJA2epapjQfEWy4QwvORn/+Rv1o=";
    dependencies = [ setuptools ];
  };

  pluggy = buildPythonPackage {
    pname = "pluggy";
    version = "1.6.0";
    hash = "sha256-fcwTC3YljTO5D2G2WHkd7eNIbD5r+wA+5cm/s5bdIvM=";
    dependencies = [
      setuptools
      setuptools-scm
    ];
  };

  tomlkit = buildPythonPackage {
    pname = "tomlkit";
    version = "0.15.1";
    hash = "sha256-4lu/OIQwBSRiEKEpgndvJ/mcub5nFg4UQ00MDSHuHpc=";
    buildBackend = "poetry";
  };

  # Uses the `calver` setuptools plugin to compute its own version dynamically at build time,
  # which needs packaging a whole separate package just to stamp a version string that nothing
  # here reads at runtime (this is just PyPI classifier data) - patch it to a static version
  # instead of packaging calver too.
  trove-classifiers = buildPythonPackage {
    pname = "trove_classifiers";
    version = "2026.9.21.13";
    hash = "sha256-Cp68jU4vPooihIxSWAMwNb7BejASrD/qFtuqdkSJ63E=";
    postPatch = ''
      substituteInPlace setup.py --replace-fail \
        'use_calver="%Y.%m.%d.%H",' 'version="2026.9.21.13",'
      substituteInPlace setup.py --replace-fail \
        '    setup_requires=["calver"],' ""
    '';
    dependencies = [ setuptools ];
  };

  pycparser = buildPythonPackage {
    pname = "pycparser";
    version = "2.21";
    hash = "sha256-5kT97BL3hy+GxY/3kNpFYhixD4Y5cCSVFtYKXqyncgY=";
    dependencies = [ setuptools ];
    pythonImportsCheck = [ "pycparser" ];
  };

  semantic-version = buildPythonPackage {
    pname = "semantic_version";
    version = "2.10.0";
    hash = "sha256-vau20zaZjLs3jUuds6S1ah4yNXAdwF6iaQ2amX7VBBw=";
  };

  setuptools = buildPythonPackage {
    pname = "setuptools";
    version = "81.0.0";
    # This version of setuptools is needed because the versions of gevent that Odoo 17, 18 & 19 uses
    # (21.8.0), still requires PEP 621, which was last supported by setuptools 81.0.0 .
    hash = "sha256-SHtTkV9SUB8Kecz9DALBZf/gZjFEOohnQLka9LelhFo=";
    pythonImportsCheck = [ "setuptools" ];
  };

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

  tomli = buildPythonPackage {
    pname = "tomli";
    version = "2.4.1";
    hash = "sha256-fH4alhoLLyRywaxbaa/6CuETLDmty2erqYVocCucwj8=";
    dependencies = [ setuptools ];
    pythonImportsCheck = [ "tomli" ];
  };

  typing-extensions = buildPythonPackage {
    pname = "typing_extensions";
    version = "4.7.1";
    hash = "sha256-t13cJk8LpWFdt7ohfa65lwGtKVNTxF+elZYzN87u/7I=";
    dependencies = [ setuptools ];
    pythonImportsCheck = [ "typing_extensions" ];
  };

  setuptools-rust = buildPythonPackage {
    pname = "setuptools-rust";
    version = "1.7.0";
    hash = "sha256-xxAJmZSCNaOK5+VV/hmapmwlPcOEsSX12FRzv4Hq46M=";
    dependencies = [
      setuptools
      semantic-version
      typing-extensions
      tomli
    ];
    pythonImportsCheck = [ "setuptools_rust" ];
  };

  # setuptools-scm's own closure already covers vcs-versioning/packaging/setuptools/tomli/
  # typing-extensions.
  zipp = buildPythonPackage {
    pname = "zipp";
    version = "3.15.0";
    hash = "sha256-ESkprWSdqUHCPeUPNWorVXDJVLZRUGQrzN1mvxlNIks=";
    dependencies = [ setuptools-scm ];
  };
}
