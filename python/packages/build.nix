# A small, self-contained alternative to nixpkgs' buildPythonPackage, targeting Wax's own
# custom-built Python interpreter instead of a nixpkgs-provided one.
# It supports a few different build backends, see below.
{
  pkgs,
  lib,
  python,
}:
let
  pythonMajorMinor = lib.versions.majorMinor python.version;
  sitePackages = "lib/python${pythonMajorMinor}/site-packages";
  pythonExecutable = "${python.package}/bin/python${pythonMajorMinor}";

  # The real implementation, with no implicit poetry-core injection - used directly to build
  # poetry-core itself (see poetry-core.nix), which obviously can't depend on itself.
  buildPythonPackageBase = lib.makeOverridable (
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
      # Which build backend drives this package, instead of the default classic `setup.py
      # build`/`install` path:
      #   - "setup.py" (default): drive `setup.py build`/`install` directly (or a synthesized
      #     `setuptools.setup()` shim when no setup.py exists), reading pyproject.toml's [project]
      #     table natively via setuptools' own PEP 621 support - regardless of the package's own
      #     *declared* build-backend (hatchling, flit_core, ...), since this path never actually
      #     invokes it.
      #   - "wheel": build a real PEP 517 wheel via setuptools.build_meta.build_wheel() and unzip it
      #     into site-packages, instead of driving `setup.py build`/`install` directly. Needed for
      #     packages whose classic install path hits distutils' install_lib.byte_compile(), which
      #     spawns a *detached* python subprocess running a bare "from distutils.util import
      #     byte_compile" script - it never imports setuptools itself, so it never gets setuptools'
      #     local-vendored-distutils shim, and hard-fails on Python 3.12+ (which removed the real
      #     stdlib distutils entirely). A real pip install never hits this at all, since pip always
      #     builds a wheel via PEP 517 and installs from that - this opts a package into the same
      #     path. Still needs `setuptools` on this package's PYTHONPATH (same as "setup.py").
      #   - "poetry": same wheel-build-then-unzip idea, but via poetry.core.masonry.api.build_wheel()
      #     - for packages whose metadata lives only in [tool.poetry] (no [project] table at all),
      #     which the "setup.py" path can't read since setuptools' PEP 621 support has no knowledge
      #     of poetry's pre-PEP-621 schema. Needs `poetry-core` on this package's PYTHONPATH.
      #   - "hatchling": same idea, via hatchling.build.build_wheel() - for packages whose [project]
      #     table the "setup.py" path technically CAN read, but where setuptools' stricter validation
      #     (unknown keys, PEP 639 license-classifier conflicts, ...) or package auto-discovery
      #     rejects metadata that hatchling itself tolerates fine. Needs `hatchling` on this package's
      #     PYTHONPATH.
      buildBackend ? "setup.py",
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
    assert
      builtins.elem buildBackend [
        "setup.py"
        "wheel"
        "poetry"
        "hatchling"
      ]
      || throw "buildPythonPackage: unsupported buildBackend '${buildBackend}' for ${pname}";
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

        # distutils' build_py.byte_compile() unconditionally tries to precompile .pyc files (used by
        # both the classic install path and bdist_wheel's underlying build step) by spawning a
        # *detached* python subprocess running a bare "from distutils.util import byte_compile"
        # script - same crash as the one --no-compile dodges below for the classic install path, but
        # bdist_wheel doesn't offer an equivalent flag to skip it. build_py.byte_compile() itself
        # checks sys.dont_write_bytecode first and returns early if set, avoiding the subprocess
        # entirely - we don't need precompiled .pyc files anyway (Python just compiles on first
        # import).
        PYTHONDONTWRITEBYTECODE = "1";

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
          if buildBackend == "wheel" then
            ''
              runHook preBuild
              mkdir -p dist
              ${pythonExecutable} -c "
              from setuptools import build_meta
              build_meta.build_wheel('dist')
              "
              runHook postBuild
            ''
          else if buildBackend == "poetry" then
            ''
              runHook preBuild
              mkdir -p dist
              ${pythonExecutable} -c "
              from poetry.core.masonry.api import build_wheel
              build_wheel('dist')
              "
              runHook postBuild
            ''
          else if buildBackend == "hatchling" then
            ''
              runHook preBuild
              mkdir -p dist
              ${pythonExecutable} -c "
              from hatchling.build import build_wheel
              build_wheel('dist')
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
          if buildBackend == "wheel" || buildBackend == "poetry" || buildBackend == "hatchling" then
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
  );

  poetryCore = import ./poetry-core.nix {
    inherit pkgs lib python;
    buildPythonPackage = buildPythonPackageBase;
  };
in
# The public builder: identical to buildPythonPackageBase, except any package using
# buildBackend = "poetry" implicitly gets poetry-core added to its nativeBuildInputs, so callers
# don't have to remember to list it themselves.
attrs:
if (attrs.buildBackend or "setup.py") == "poetry" then
  assert
    poetryCore != null
    || throw "buildPythonPackage: buildBackend \"poetry\" requires python >=3.10 (poetry-core's own requires-python floor), for ${attrs.pname}";
  buildPythonPackageBase (
    attrs // { nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ [ poetryCore ]; }
  )
else
  buildPythonPackageBase attrs
