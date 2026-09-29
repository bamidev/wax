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
    version = "59.6.0";
    hash = "sha256-Isc0jG0pdqUmMsZ/erDN9AFH23eJ+a7RhzRkP+nPM3M=";
    pythonImportsCheck = [ "setuptools" ];
  };

  # 21.3's own install_requires lists pyparsing (later packaging releases dropped that dependency).
  pyparsing = buildPythonPackage {
    pname = "pyparsing";
    version = "2.2.0";
    hash = "sha256-CDK89HrNKDeIWT56D1QkB72VUKVaioQ1IUoZYOBLywQ=";
    nativeBuildInputs = [ setuptools ];
    pythonImportsCheck = [ "pyparsing" ];
  };

  packaging = buildPythonPackage {
    pname = "packaging";
    version = "21.3";
    hash = "sha256-3UfEKSfYmrkR5gZRiQfMLTofOLvQJjhZcGQ/nFuOz+s=";
    nativeBuildInputs = [
      pyparsing
      setuptools
    ];
    pythonImportsCheck = [ "packaging" ];
  };

  # Ships no setup.py, only a static [project] table in pyproject.toml (always has - it's a
  # PEP 517-first project, unlike typing_extensions there's no older release with a real
  # setup.py to fall back to). Our generic fallback needs setuptools>=61 to read that table, but
  # 3.6 is stuck on 59.6.0 (61+ requires python>=3.7), so it installs an empty "UNKNOWN" package
  # instead. Synthesize a real setup.py instead.
  tomli = buildPythonPackage {
    pname = "tomli";
    version = "1.2.3";
    hash = "sha256-BbYWa/9IfcBo0yJYXH6k73je7VAcwSQGDg8jjompIx8=";
    nativeBuildInputs = [ setuptools ];
    postPatch = ''
      cat > setup.py <<'EOF'
      from setuptools import setup
      setup(name="tomli", version="1.2.3", packages=["tomli"])
      EOF
    '';
    pythonImportsCheck = [ "tomli" ];
  };

  setuptools-scm = buildPythonPackage {
    pname = "setuptools_scm";
    version = "6.4.2";
    hash = "sha256-aDOsZcbtlxGk1dImb4Akz6B8UzoOVfTBL27/KApanjA=";
    nativeBuildInputs = [
      packaging
      setuptools
      tomli
    ];
    pythonImportsCheck = [ "setuptools_scm" ];
  };

  # 4.1.1 (used for 3.7) ships no setup.py, only a static [project] table in pyproject.toml. Our
  # generic fallback (calling setup() with no args and letting setuptools read pyproject.toml
  # itself) needs setuptools>=61 for that, but 3.6 is stuck on 59.6.0 (61+ requires python>=3.7).
  # 3.10.0.2 is the last release with a real setup.py, and still satisfies setuptools-rust's
  # typing_extensions>=3.7.4.3 requirement.
  typing-extensions = buildPythonPackage {
    pname = "typing_extensions";
    version = "3.10.0.2";
    hash = "sha256-SfddFv8R8c0ljhuYjM/4KjylVwIX162MX0ggXdmaZ34=";
    nativeBuildInputs = [ setuptools ];
    pythonImportsCheck = [ "typing_extensions" ];
  };

  semantic-version = buildPythonPackage {
    pname = "semantic_version";
    version = "2.10.0";
    hash = "sha256-vau20zaZjLs3jUuds6S1ah4yNXAdwF6iaQ2amX7VBBw=";
  };

  # setuptools-rust 1.1.2 itself doesn't parse toml, but tomli still needs to be here: it's
  # setuptools_scm's own unmet dependency, and setup_requires resolution checks it eagerly.
  setuptools-rust = buildPythonPackage {
    pname = "setuptools-rust";
    version = "1.1.2";
    hash = "sha256-oK25tQPA/8To/oC3xheJjO+ngEmYOqrqf3R+FTo+ZdE=";
    nativeBuildInputs = [
      packaging
      pyparsing
      semantic-version
      setuptools
      setuptools-scm
      tomli
      typing-extensions
    ];
    pythonImportsCheck = [ "setuptools_rust" ];
  };

  pycparser = buildPythonPackage {
    pname = "pycparser";
    version = "2.21";
    hash = "sha256-5kT97BL3hy+GxY/3kNpFYhixD4Y5cCSVFtYKXqyncgY=";
    nativeBuildInputs = [ setuptools ];
    pythonImportsCheck = [ "pycparser" ];
  };

  cffi = buildPythonPackage {
    pname = "cffi";
    version = "1.15.1";
    hash = "sha256-1AC/uaN7E1ElPLQCZxzqfom97MKU6AFqcH9tHYrJNPk=";
    nativeBuildInputs = [
      pkgs.pkg-config
      pycparser
      setuptools
    ];
    # Python 3.6.15's pyconfig.h declares HAVE_CRYPT_H, so Python.h pulls in <crypt.h> - needed by
    # any extension that includes it, not just python's own build.
    buildInputs = with pkgs; [
      libffi
      libxcrypt-legacy
    ];
    pythonImportsCheck = [ "cffi" ];
  };
}
