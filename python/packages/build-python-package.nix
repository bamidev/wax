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
    # Path to a Cargo.lock to vendor offline (e.g. "${src}/Cargo.lock", which needs `src` to be an
    # extracted directory - fetchzip, not fetchPypi/fetchurl - so the file is readable at eval
    # time). Needed for packages that build a Rust extension via setuptools-rust (declared through
    # a `[[tool.setuptools-rust.ext-modules]]` pyproject.toml table, which setuptools-rust's own
    # setuptools entry point picks up automatically - no setup.py changes needed): `cargo build`
    # would otherwise need crates.io network access, which the sandbox blocks.
    cargoLockFile ? null,
    # Subdirectory (relative to the unpacked source root) containing Cargo.toml/Cargo.lock, when
    # it's not the sdist's top level (e.g. cryptography's is under "src/rust") - cargoSetupHook's
    # own consistency check between the source tree's Cargo.lock and the vendored one otherwise
    # always looks at the source root.
    cargoRoot ? null,
    # Build via a real PEP 517 wheel (setuptools.build_meta.build_wheel + unzip into
    # site-packages) instead of driving `setup.py build`/`install` directly. Needed for packages
    # whose classic install path hits distutils' install_lib.byte_compile(), which spawns a
    # *detached* python subprocess running a bare "from distutils.util import byte_compile"
    # script - it never imports setuptools itself, so it never gets setuptools'
    # local-vendored-distutils shim, and hard-fails on Python 3.12+ (which removed the real
    # stdlib distutils entirely). A real pip install never hits this at all, since pip always
    # builds a wheel via PEP 517 and installs from that - this opts a package into the same path.
    buildViaWheel ? false,
    nativeBuildInputs ? [ ],
    buildInputs ? [ ],
    propagatedBuildInputs ? [ ],
    # Python packages (built via this same function) that this package's code actually imports.
    # Unlike nativeBuildInputs, this recursively expands: each listed dependency's own
    # `dependencies` (and theirs, and so on) come along automatically via its
    # passthru.pythonDependencyClosure, computed once when *that* package itself was built. So you
    # only need to list this package's own direct imports here, not its whole transitive runtime
    # import closure by hand. PYTHONPATH is otherwise completely flat/non-transitive (each package
    # is its own isolated derivation, and we don't use pip/a venv to resolve dependencies) - e.g. if
    # A depends on B and B depends on C, A needing C on its own PYTHONPATH even though A never
    # imports C directly, only because B does.
    dependencies ? [ ],
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
  let
    transitiveDependencies = lib.unique (
      dependencies ++ builtins.concatMap (dep: dep.passthru.pythonDependencyClosure or [ ]) dependencies
    );
  in
  pkgs.stdenv.mkDerivation (
    {
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

      nativeBuildInputs =
        nativeBuildInputs
        ++ transitiveDependencies
        ++ lib.optionals (cargoLockFile != null) [
          pkgs.rustPlatform.cargoSetupHook
          pkgs.cargo
          pkgs.rustc
        ];
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
      # (declared as native/propagated build inputs, or via `dependencies` - see above) on
      # PYTHONPATH ourselves.
      PYTHONPATH = lib.makeSearchPath sitePackages (
        nativeBuildInputs ++ transitiveDependencies ++ propagatedBuildInputs
      );

      # Some old sdists' setup.py call `distutils.core.setup` directly instead of importing
      # setuptools themselves, which means plain distutils' `install` command runs instead of
      # setuptools' (e.g. it won't recognise --single-version-externally-managed below). Force
      # setuptools to be imported first, the same way pip's legacy setup.py invocation does, so
      # setuptools' monkeypatched build/install commands are used regardless of what setup.py
      # itself imports. This requires setuptools to be a nativeBuildInput (except when building
      # setuptools itself, which is self-hosted from its own checkout on PYTHONPATH via cwd).
      buildPhase =
        if buildViaWheel then
          ''
            runHook preBuild
            mkdir -p dist
            ${pythonExecutable} -c "
            from setuptools import build_meta
            build_meta.build_wheel('dist')
            "
            runHook postBuild
          ''
        else
          ''
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

      installPhase =
        if buildViaWheel then
          ''
            runHook preInstall
            mkdir -p $out/${sitePackages}
            ${pythonExecutable} -m zipfile -e dist/*.whl $out/${sitePackages}
            runHook postInstall
          ''
        else
          ''
            runHook preInstall
            mkdir -p $out/${sitePackages}
            # distutils' own install_lib.byte_compile() spawns a *separate* python subprocess running
            # a bare "from distutils.util import byte_compile" script - it never imports setuptools
            # first, so it never gets setuptools' local-vendored-distutils shim, and fails outright on
            # Python 3.12+ (which removed the real stdlib distutils entirely). We don't need
            # precompiled .pyc files anyway (Python just compiles on first import), so skip it.
            PYTHONPATH="$out/${sitePackages}:$PYTHONPATH" run_setup_py install \
              --prefix=$out \
              --single-version-externally-managed \
              --root=/ \
              --record=/dev/null \
              --no-compile
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
        pythonDependencyClosure = transitiveDependencies;
      };
    }
    // lib.optionalAttrs (cargoLockFile != null) {
      cargoDeps = pkgs.rustPlatform.importCargoLock { lockFile = cargoLockFile; };
    }
    // lib.optionalAttrs (cargoRoot != null) { inherit cargoRoot; }
  )
)
