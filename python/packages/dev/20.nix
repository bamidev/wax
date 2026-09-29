# Developer-tooling python packages for odoo 20 (python 3.12), built on top of dev/19.nix (python
# 3.10). Reuses every package as-is except autopep8/pycodestyle/pyflakes/wrapt/Deprecated, which
# get newer releases here (all confirmed python-3.12-compatible) - and everything that
# transitively references one of those five gets a matching fresh definition too, since
# dev/19.nix is a `rec {}` and its own internal references would otherwise keep resolving to the
# un-bumped versions there.
{
  pkgs,
  lib,
  python,
  pythonDefaultPackages,
  odooPackages,
}:
let
  pythonPackage = python.pythonPackage pythonDefaultPackages;
  dev19 = import ./19.nix {
    inherit
      pkgs
      lib
      python
      pythonDefaultPackages
      odooPackages
      ;
  };
in
rec {
  inherit (dev19)
    astroid
    beniget
    black
    click
    cssselect
    debugpy
    dill
    docstring-to-markdown
    gast
    frilouz
    isort
    jedi
    mccabe
    memestra
    mypy
    mypy-extensions
    openupgradelib
    parso
    pydocstyle
    pylint
    pylint-odoo
    pylint-plugin-utils
    pytokens
    pyyaml
    rope
    snowballstemmer
    ujson
    whatthepatch
    yapf
    python-lsp-jsonrpc
    ;

  pycodestyle = pythonPackage {
    pname = "pycodestyle";
    version = "2.15.0";
    hash = "sha256-MY9dsIOGm0xNrZItCxEST7J6sYG2cwuTNx2mceMb1Q4=";
  };

  pyflakes = pythonPackage {
    pname = "pyflakes";
    version = "4.0.0";
    hash = "sha256-SSsnc1GB49SmrPwIc4lItma/PmlngYVOpuDYVA1WbVI=";
  };

  autopep8 = pythonPackage {
    pname = "autopep8";
    version = "2.3.2";
    hash = "sha256-iUQKT5aRl7aamV5M4GYbAx9FWp93bSxbo9vYNGaTF1g=";
    nativeBuildInputs = [ pycodestyle ];
  };

  # dev/19.nix pins wrapt to 1.x specifically because its Deprecated 1.2.18 requires wrapt<2;
  # 3.0.0 below allows wrapt>=1.16,<3 so 2.x works here.
  wrapt = pythonPackage {
    pname = "wrapt";
    version = "2.5.0";
    hash = "sha256-xIzbbJBNynbZkVpXnkpfq2sMJfZQwQGc54p47/r3o0U=";
  };

  # 3.0.0 requires python>=3.12 exactly (a rewrite that dropped everything older) - not usable on
  # dev/19.nix's python 3.10, but a perfect fit here.
  deprecated = pythonPackage {
    pname = "Deprecated";
    version = "3.0.0";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/f7/9c/16649913bf14c73e0a9453782e148362ff2657067deff6aa9c7ebcddcc31/deprecated-3.0.0.tar.gz";
      hash = "sha256-FoUCBNOh5rsKzQa/9I2W6LCg0l0cUvcXBUBaD0iUGS0=";
    };
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail \
        'dynamic = ["version"]' 'version = "3.0.0"'
    '';
    dependencies = [ wrapt ];
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

  python-lsp-black = pythonPackage {
    pname = "python-lsp-black";
    version = "2.0.0";
    hash = "sha256-gobS0xDFZoRLPBFrgkrab8z6a6IosaCaBSa3TATggF8=";
    nativeBuildInputs = [
      black
      python-lsp-server
    ];
  };

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
}
