# Developer-tooling python packages (LSP server + plugins, linters, debugger) for the venv, scoped
# to odoo 19 only for now (see flake.nix's defaultConfig.dev.pythonPackages) - not yet ported to
# other odoo major versions.
{
  pkgs,
  lib,
  python,
  pythonDefaultPackages,
  odooPackages,
}:
let
  pythonPackage = python.pythonPackage pythonDefaultPackages;
in
rec {
  # Left out for now: nbformat, nbconvert (memestra's Jupyter-notebook-support dependency) pull in
  # a whole new transitive tree (jsonschema, jupyter_core, traitlets, ...).

  astroid = pythonPackage {
    pname = "astroid";
    version = "4.3.2";
    hash = "sha256-jNr1t/P085VXrgXtiwhSE2tDoEq2htt9OSVbIGIzZ3o=";
    buildBackend = "wheel";
  };

  autopep8 = pythonPackage {
    pname = "autopep8";
    version = "2.0.4";
    hash = "sha256-KRMGSr2Xs0GdHMg+px8ELLgh+H5FuciMrVrTxOqH/gw=";
    nativeBuildInputs = [ pycodestyle ];
  };

  beniget = pythonPackage {
    pname = "beniget";
    version = "0.5.0";
    hash = "sha256-568R+o7H3j0+s9mLHnItFdRAF9izXYqhHVT2cZsxLyI=";
    nativeBuildInputs = [ gast ];
  };

  black = pythonPackage {
    pname = "black";
    version = "26.5.1";
    hash = "sha256-3TIfZoBTlhgkvMG+HMHfdIstfk+igIawgzHld7AQCnM=";
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail \
        'dynamic = ["readme", "version"]' \
        'version = "26.5.1"
      readme = "README.md"'
    '';
    nativeBuildInputs = [
      odooPackages.platformdirs
      pythonDefaultPackages.packaging
      pythonDefaultPackages.pathspec
      pythonDefaultPackages.tomli
      pytokens
    ];
  };

  click = pythonPackage {
    pname = "click";
    version = "8.5.0";
    hash = "sha256-ug0gid516gMQ4t3gMWDmyhAAmUf7laGC+bVAIbsnLjQ=";
  };

  cssselect = pythonPackage {
    pname = "cssselect";
    version = "1.5.0";
    hash = "sha256-PL6C3XrL7pup5XI7X55HSYJpEvH7Mc1/kqq+1f3hWxU=";
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail \
        'dynamic = ["version"]' 'version = "1.5.0"'
    '';
  };

  debugpy = pythonPackage {
    pname = "debugpy";
    version = "1.8.22";
    hash = "sha256-5InHJo4ce0HhO0ONnFM9Knr3P7Wb+M0w/q2ChsHDnE4=";
  };

  deprecated = pythonPackage {
    pname = "Deprecated";
    version = "1.2.18";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/98/97/06afe62762c9a8a86af0cfb7bfdab22a43ad17138b07af5b1a58442690a2/deprecated-1.2.18.tar.gz";
      hash = "sha256-QitvbYWdpvLvV4V3Yb+zkkgFAqZMMCjKm76GCF1yEV0=";
    };
    dependencies = [ wrapt ];
  };

  dill = pythonPackage {
    pname = "dill";
    version = "0.4.1";
    hash = "sha256-QjCS30GCF31Ni6gpDIpbZAxmqzXsfaWcz6APb6Pupfo=";
  };

  # fetchPypi's legacy "/packages/source/<letter>/<pname>/..." URL 404s for this release (PyPI
  # retired that path for newer uploads); fetch from the real hash-bucketed URL instead.
  docstring-to-markdown = pythonPackage {
    pname = "docstring-to-markdown";
    version = "0.17";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/52/d8/8abe80d62c5dce1075578031bcfde07e735bcf0afe2886dd48b470162ab4/docstring_to_markdown-0.17.tar.gz";
      hash = "sha256-33KhEilMdJJIfJ2iRRyuD67uBuhgCCRcGIxXYclZDKM=";
    };
  };

  flake8 = pythonPackage {
    pname = "flake8";
    version = "7.4.1";
    hash = "sha256-hOpa/K80RIew6luq67gQD0z668AfdVmY91h2ZkAp9Yc=";
    nativeBuildInputs = [
      mccabe
      pycodestyle
      pyflakes
    ];
  };

  gast = pythonPackage {
    pname = "gast";
    version = "0.7.0";
    hash = "sha256-C7FM0bgGci6R3bq2+4a7oUjCK0Dn/xHiSJdOBMit/a4=";
  };

  frilouz = pythonPackage {
    pname = "frilouz";
    version = "0.0.2";
    hash = "sha256-unki82UA9upKaOh/nNJP5KARqYZzy3q0x8PvzTNkelk=";
  };

  isort = pythonPackage {
    pname = "isort";
    version = "9.0.2";
    hash = "sha256-0imJgM5ENQ8R2dJMgVDq7xiDQx7CA93btOm1w861THA=";
    buildBackend = "hatchling";
    dependencies = [
      mypy-extensions
      pythonDefaultPackages.hatchling
    ];
  };

  jedi = pythonPackage {
    pname = "jedi";
    version = "0.20.0";
    hash = "sha256-w/TMvSdmlvSxnFRhjU+xj5/CSwrvAqz3BLI/SH2qEBE=";
    nativeBuildInputs = [ parso ];
  };

  mccabe = pythonPackage {
    pname = "mccabe";
    version = "0.7.0";
    hash = "sha256-NI4CQMM7YLvfTlIxku+RnyjLLD19XHeU90AJKQ8jYyU=";
  };

  memestra = pythonPackage {
    pname = "memestra";
    version = "0.2.1";
    hash = "sha256-6shwf9BoDfZMy0itP8esNP4ov6fw6LJpO3Y5ZahwDZw=";
    nativeBuildInputs = [
      beniget
      frilouz
      gast
      pyyaml
    ];
  };

  mypy = pythonPackage {
    pname = "mypy";
    version = "2.3.1";
    hash = "sha256-R8GxIHJYUTqdk0lfaci+nec5FhhvDlJwPoxGG3piNBk=";
    dependencies = [
      mypy-extensions
      pythonDefaultPackages.pathspec
      pythonDefaultPackages.typing-extensions
    ];
  };

  mypy-extensions = pythonPackage {
    pname = "mypy_extensions";
    version = "1.1.0";
    hash = "sha256-UuaO/DKEhh53K7zWaCP95a4h/S/bUcYqIRQDcwuRZVg=";
  };

  openupgradelib = pythonPackage {
    pname = "openupgradelib";
    version = "3.13.7";
    hash = "sha256-tKu3z31EInW2QojXoGZeCHAUGTtt/tSidBKVvIgA8YA=";
    dependencies = [
      cssselect
      odooPackages.lxml
    ];
  };

  parso = pythonPackage {
    pname = "parso";
    version = "0.8.7";
    hash = "sha256-6qrEyf3V6eiFLcd40tdAWJfsUQ8qKYBxRT5eOgeRS7E=";
  };

  pycodestyle = pythonPackage {
    pname = "pycodestyle";
    version = "2.12.1";
    hash = "sha256-aDjq4Iu85PaszV1VcgdcY2JqFe4+b4Qt+Za/YvbXNSE=";
  };

  pydocstyle = pythonPackage {
    pname = "pydocstyle";
    version = "6.3.0";
    hash = "sha256-fOQ/DArIewdJTrnAtGLAtz5v8naAfyBNa1Ptxyt+ROE=";
    nativeBuildInputs = [ snowballstemmer ];
  };

  pyflakes = pythonPackage {
    pname = "pyflakes";
    version = "3.2.0";
    hash = "sha256-HGFgP/FUYh+yqRcgN9hNyjUA3vjItjBlfRcB8Cb4rz8=";
  };

  pylint = pythonPackage {
    pname = "pylint";
    version = "4.0.9";
    hash = "sha256-bxMFeAIprnIOibiv8rP/hXy7Jo+6uYyLWGlgJnZnrTQ=";
    buildBackend = "wheel";
    nativeBuildInputs = [
      astroid
      dill
      mccabe
      odooPackages.platformdirs
      pythonDefaultPackages.tomli
    ];
  };

  # fetchPypi's legacy "/packages/source/<letter>/<pname>/..." URL 404s for this release (PyPI
  # retired that path for newer uploads); fetch from the real hash-bucketed URL instead.
  pylint-odoo = pythonPackage {
    pname = "pylint-odoo";
    version = "10.0.11";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/25/6f/240719fb42d13ccf4f8e07217af46839b2c3ed29d567e0c695c1ff7689cc/pylint_odoo-10.0.11.tar.gz";
      hash = "sha256-BUMNbxcse7u0kCwC2+FTgvTvctxJ5socjYToBe6bTAE=";
    };
    nativeBuildInputs = [ pylint ];
  };

  pylint-plugin-utils = pythonPackage {
    pname = "pylint_plugin_utils";
    version = "0.9.0";
    hash = "sha256-VGjXY4eKGNXMTbRur/3aFDE7BDyWKiY6fXgVG5ATIFU=";
    buildBackend = "poetry";
    dependencies = [ pylint ];
  };

  # fetchPypi's legacy "/packages/source/<letter>/<pname>/..." URL 404s for this release (PyPI
  # retired that path for newer uploads); fetch from the real hash-bucketed URL instead.
  pylsp-mypy = pythonPackage {
    pname = "pylsp-mypy";
    version = "0.8.0";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/c2/d3/25f5fdecdeebee9f896b45011a03657bfd7b85503659ddee20e9a97bec7e/pylsp_mypy-0.8.0.tar.gz";
      hash = "sha256-ANhur6TlRO6Bpzl57/GpmPvUDUrpwYIf6IAjMmp1bcI=";
    };
    buildBackend = "wheel";
    nativeBuildInputs = [
      mypy
      python-lsp-server
    ];
  };

  pyls-memestra = pythonPackage {
    pname = "pyls-memestra";
    version = "0.0.16";
    hash = "sha256-zMVDd2uB4znw38z3yb0Nt7qQH5dGHTbQBIZO/qo1/t8=";
    dependencies = [
      deprecated
      memestra
      python-lsp-server
    ];
  };

  # fetchPypi's legacy "/packages/source/<letter>/<pname>/..." URL 404s for this release (PyPI
  # retired that path for newer uploads); fetch from the real hash-bucketed URL instead.
  pylsp-rope = pythonPackage {
    pname = "pylsp-rope";
    version = "0.1.17";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/51/3d/cfcf7e093c98cccadbccdc8762194cd3afaa4d8aac6731ced5bea92489cb/pylsp_rope-0.1.17.tar.gz";
      hash = "sha256-TNby+zLIQwK5TLTOACvAcAsbZW3VFH59s92SMDqajcI=";
    };
    nativeBuildInputs = [
      python-lsp-server
      rope
    ];
  };

  python-lsp-black = pythonPackage {
    pname = "python-lsp-black";
    version = "2.0.0";
    hash = "sha256-gobS0xDFZoRLPBFrgkrab8z6a6IosaCaBSa3TATggF8=";
    nativeBuildInputs = [
      black
      python-lsp-server
    ];
  };

  python-lsp-isort = pythonPackage {
    pname = "python-lsp-isort";
    version = "0.2.1";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/cd/d6/00eafcec154eb4f18b1148ca4fba67add69678e700dfcff5f8e19abe1aa8/python_lsp_isort-0.2.1.tar.gz";
      hash = "sha256-LzevPGMTKRakA3fDI4l9dDVGRwp154sJb8iPyumXUls=";
    };
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail \
        'dynamic = ["version"]' 'version = "0.2.1"'
    '';
    dependencies = [
      isort
      python-lsp-server
    ];
  };

  python-lsp-jsonrpc = pythonPackage {
    pname = "python-lsp-jsonrpc";
    version = "1.1.2";
    hash = "sha256-RojkU+71XNlSv/dixwXO3voSBVwK7Begb1lbzAAsyRI=";
    buildBackend = "wheel";
    nativeBuildInputs = [ ujson ];
  };

  # fetchPypi's legacy "/packages/source/<letter>/<pname>/..." URL 404s for this release (PyPI
  # retired that path for newer uploads); fetch from the real hash-bucketed URL instead.
  python-lsp-server = pythonPackage {
    pname = "python-lsp-server";
    version = "1.15.0";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/e6/63/7d6af072a5b77a0d1f61306b7a72a7a2bc3f29ec0f8a8c85eb23f5ba7716/python_lsp_server-1.15.0.tar.gz";
      hash = "sha256-hfoJAmLD0a7wm3WdmIEdbLmtW7xYrxXViGCK6MGSWAE=";
    };
    nativeBuildInputs = [
      autopep8
      black
      docstring-to-markdown
      flake8
      jedi
      mccabe
      pycodestyle
      pydocstyle
      pyflakes
      pylint
      python-lsp-jsonrpc
      pythonDefaultPackages.pluggy
      rope
      ujson
      whatthepatch
      yapf
    ];
    pythonImportsCheck = [ "pylsp" ];
  };

  pytokens = pythonPackage {
    pname = "pytokens";
    version = "0.4.1";
    hash = "sha256-KSBS/oCSOq4iYMBz+CLOuiHzhyztmmi7eVOzSOVhF5o=";
    # setup.py defaults to an optional mypyc-compiled speedup on CPython, needing a full mypyc
    # build toolchain we don't have; this env var (setup.py's own documented escape hatch) skips
    # it in favor of the plain Python implementation.
    preBuild = ''
      export PYTOKENS_USE_MYPYC=0
    '';
  };

  pyyaml = pythonPackage {
    pname = "PyYAML";
    version = "6.0.3";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz";
      hash = "sha256-12YjNzQh3yL7TPiBcCDLt+8VxyW51eRfF+GJv8OEGQ8=";
    };
  };

  rope = pythonPackage {
    pname = "rope";
    version = "1.15.0";
    hash = "sha256-qegsn1yloQVDh8Iv32yd6elIr1VhOL2lfU2oHTN4eTo=";
  };

  snowballstemmer = pythonPackage {
    pname = "snowballstemmer";
    version = "3.1.1";
    hash = "sha256-4Hu8VKDXmP5gEKEjmEIuYqi/u6lcOU/QlW71jLTT4mA=";
  };

  ujson = pythonPackage {
    pname = "ujson";
    version = "6.0.0";
    hash = "sha256-gOIzk/63B1guCtSVw5ekR3tkbQgJTS32T3MW+fr9iq4=";
  };

  whatthepatch = pythonPackage {
    pname = "whatthepatch";
    version = "1.0.7";
    hash = "sha256-nu+06+pSAECOAtQT0rS8KNrqa3i7S01TQxr3JF99ft8=";
    buildBackend = "wheel";
  };

  wrapt = pythonPackage {
    pname = "wrapt";
    version = "1.17.3";
    hash = "sha256-9m6wj+qkEP5O69F/KiyOLkbTR26fjHg9qo4J4PqmZtA=";
  };

  yapf = pythonPackage {
    pname = "yapf";
    version = "0.43.0";
    hash = "sha256-ANOqJL/t/5QgsuDV2fWrbZ1CaOcq+/Wbs/pUJ4HVIY4=";
    buildBackend = "wheel";
    nativeBuildInputs = [
      odooPackages.platformdirs
      pythonDefaultPackages.tomli
    ];
  };
}
