# A small, self-contained alternative to nixpkgs' buildPythonPackage, targeting Wax's own
# custom-built Python interpreter instead of a nixpkgs-provided one. It doesn't use pip: it
# drives distutils/setuptools directly (`setup.py build` / `setup.py install`).
#
# Only the "setuptools" format (a plain setup.py-based sdist) is implemented so far. PEP517-only
# backends (hatchling, poetry-core, maturin, ...) aren't supported yet; add handling for those as
# we run into packages that need them.
{
  pkgs,
  lib,
  python,
}:
let
  pythonMajorMinor = lib.versions.majorMinor python.version;
  sitePackages = "lib/python${pythonMajorMinor}/site-packages";
  pythonExecutable = "${python.package}/bin/python${pythonMajorMinor}";
in
lib.makeOverridable (
  {
    pname,
    version,
    # By default the source is fetched from PyPI using pname/version/hash. Pass `src` directly
    # to fetch from somewhere else instead (e.g. a GitHub checkout), in which case `hash` isn't
    # used here.
    src ? pkgs.fetchPypi {
      inherit
        pname
        version
        hash
        extension
        ;
    },
    hash ? null,
    # PyPI sdist file extension. Most old sdists are .tar.gz, some are .zip.
    extension ? "tar.gz",
    format ? "setuptools",
    nativeBuildInputs ? [ ],
    buildInputs ? [ ],
    propagatedBuildInputs ? [ ],
    # Module names to try importing after install, as a cheap smoke test.
    pythonImportsCheck ? [ ],
    patches ? [ ],
    postPatch ? "",
    preBuild ? "",
    preInstall ? "",
    postInstall ? "",
    setupPyBuildFlags ? [ ],
    meta ? { },
  }:
  assert
    format == "setuptools"
    || throw "buildPythonPackage: unsupported format '${format}' for ${pname} (only \"setuptools\" is implemented so far)";
  pkgs.stdenv.mkDerivation {
    pname = "python${pythonMajorMinor}-${pname}";
    inherit version src;

    inherit
      patches
      postPatch
      preBuild
      preInstall
      postInstall
      meta
      ;

    inherit nativeBuildInputs;
    buildInputs = buildInputs ++ propagatedBuildInputs;
    propagatedBuildInputs = propagatedBuildInputs;

    # Packages that version themselves via setuptools_scm can't detect a version from a bare
    # PyPI sdist tarball (no .git directory) and fail with "unable to detect version". This is
    # setuptools_scm's own documented escape hatch for that case; it's a no-op for packages that
    # don't use setuptools_scm.
    SETUPTOOLS_SCM_PRETEND_VERSION = version;

    # The nix sandbox has no locale configured, so anything reading non-ASCII bytes from a
    # metadata file (e.g. configparser parsing setup.cfg) fails with UnicodeDecodeError on
    # Python < 3.7 - unlike 3.7+, which auto-coerces to a UTF-8 locale at startup (PEP 538).
    # Harmless on newer Python versions, so set unconditionally rather than only for old ones.
    LOCALE_ARCHIVE = "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive";
    LANG = "en_US.UTF-8";

    # We don't use pip or a venv to resolve dependencies, so put sibling Python packages
    # (declared as native/propagated build inputs) on PYTHONPATH ourselves.
    PYTHONPATH = lib.makeSearchPath sitePackages (nativeBuildInputs ++ propagatedBuildInputs);

    # Some old sdists' setup.py call `distutils.core.setup` directly instead of importing
    # setuptools themselves, which means plain distutils' `install` command runs instead of
    # setuptools' (e.g. it won't recognise --single-version-externally-managed below). Force
    # setuptools to be imported first, the same way pip's legacy setup.py invocation does, so
    # setuptools' monkeypatched build/install commands are used regardless of what setup.py
    # itself imports. This requires setuptools to be a nativeBuildInput (except when building
    # setuptools itself, which is self-hosted from its own checkout on PYTHONPATH via cwd).
    buildPhase = ''
      runHook preBuild
      run_setup_py() {
        ${pythonExecutable} -c "import setuptools; __file__ = 'setup.py'; exec(compile(open(__file__).read(), __file__, 'exec'))" "$@"
      }
      # Some newer sdists are configured purely via pyproject.toml's [project] table (PEP 621)
      # and ship no setup.py at all. setuptools can read that table itself when setup() is called
      # with no arguments, so synthesize a trivial shim when one is missing.
      if [ ! -e setup.py ]; then
        echo "from setuptools import setup; setup()" > setup.py
      fi
      run_setup_py build ${lib.escapeShellArgs setupPyBuildFlags}
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/${sitePackages}
      PYTHONPATH="$out/${sitePackages}:$PYTHONPATH" run_setup_py install \
        --prefix=$out \
        --single-version-externally-managed \
        --root=/ \
        --record=/dev/null
      runHook postInstall
    '';

    doInstallCheck = pythonImportsCheck != [ ];
    installCheckPhase = ''
      PYTHONPATH="$out/${sitePackages}:$PYTHONPATH" ${pythonExecutable} -c '${
        lib.concatMapStringsSep "; " (moduleName: "import ${moduleName}") pythonImportsCheck
      }'
    '';

    passthru = {
      inherit sitePackages pname version;
    };
  }
)
