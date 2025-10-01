{
  description = "A flake to manage odoo with git-aggregator and pip";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    { self, nixpkgs }:
    {
      lib.mkOdooShell =
        { system, config }:
        let
          lib = nixpkgs.lib;

          defaultConfig = {
            dev.pythonPackages = [
              "debugpy"
              "python-lsp-server[all]"
              "git+https://github.com/ddejong-therp/odoo-repl@master"
            ];

            reposDefaultRef = config.odooVersion;
          };
          completeConfig = lib.attrsets.recursiveUpdate defaultConfig config;

          odooMajorVersion = lib.strings.toInt (lib.versions.major config.odooVersion);

          pkgs = nixpkgs.legacyPackages.${system};

          python = rec {
            version =
              if odooMajorVersion < 11 then
                "2.7.18"
              else if odooMajorVersion < 13 then
                "3.5.10"
              else if odooMajorVersion < 15 then
                "3.6.15"
              else if odooMajorVersion < 17 then
                "3.8.20"
              else
                "3.10.15";
            majorVersion = lib.strings.toInt (lib.versions.major version);
            minorVersion = lib.strings.toInt (lib.versions.minor version);

            package = pkgs.stdenv.mkDerivation (finalAttrs: rec {
              pname = "python";
              version = python.version;
              src = pkgs.fetchurl {
                url = "https://www.python.org/ftp/python/${finalAttrs.version}/Python-${finalAttrs.version}.tar.xz";
                hash =
                  if finalAttrs.version == "2.7.18" then
                    "sha256-tiwOeTdVHQzAK4/Vyw9UT5QFuvyaVNOAjtRZSBLt70M="
                  else if finalAttrs.version == "3.5.10" then
                    "sha256-Dw+oaFwdwfHaywtOd3l5a5Cu+Z3B+klnpxudp7V9Sig="
                  else if finalAttrs.version == "3.6.15" then
                    "sha256-bijXzdbdUT3RkOSbyjly4g/PRVCQzPLvPxoidhQTXZE="
                  else if finalAttrs.version == "3.8.20" then
                    "sha256-b7iacSQgHGESXAq0z39olN8zmkDAKDO/0oq012kfr7Q="
                  else if finalAttrs.version == "3.10.15" then
                    "sha256-qrCVCBdzUXJgGHmHLZN8HkkopXxAmuAjaew9kdzOvnk="
                  else
                    "unsupported python version";
              };
              buildInputs = with pkgs; [
                bzip2
                cyrus_sasl
                libffi
                libxcrypt-legacy
                ncurses
                openldap
                openssl
                readline
                zlib
              ];
              configureFlags = with pkgs; [
                "--with-openssl=${openssl.dev}"
                "--with-pkg-config=yes"
              ];
              preConfigure = with pkgs; ''
                export CPPFLAGS="-I${zlib.dev}/include -I${libffi.dev}/include "\
                "-I${readline.dev}/include "\
                "-I${bzip2.dev}/include -I${openssl.dev}/include";
                export CXXFLAGS="$CPPFLAGS";
                export CFLAGS="-I${openssl.dev}/include";
                export LDFLAGS="-L${zlib.out}/lib -L${libffi.out}/lib -L${readline.out}/lib -L${bzip2.out}/lib -L${openssl.out}/lib";
              '';
              preBuild = preConfigure;

              # See https://bugs.python.org/issue45700
              # Credits to nixpkgs-python: https://github.com/cachix/nixpkgs-python/blob/main/flake.nix
              patches =
                lib.optionals
                  (
                    majorVersion == 3
                    && (builtins.elem minorVersion [
                      5
                      6
                    ])
                  )
                  [
                    (pkgs.fetchpatch {
                      url = "https://github.com/python/cpython/commit/8766cb74e186d3820db0a855.patch";
                      sha256 = "IzAp3M6hpSNcbVRttzvXNDyAVK7vLesKZDEDkdYbuww=";
                    })
                    (pkgs.fetchpatch {
                      url = "https://github.com/python/cpython/commit/f0be4bbb9b3cee876249c23f.patch";
                      sha256 = "FUF7ZkkatS4ON4++pR9XJQFQLW1kKSVzSs8NAS19bDY=";
                    })
                  ];
            });

            pipVersion =
              if majorVersion == 2 || minorVersion < 6 then
                "20.3.4"
              else if minorVersion == 6 then
                "21.3.1"
              else if minorVersion == 8 then
                "25.0.1"
              else
                "25.1.1";
          };

          commands = {
            build = pkgs.writers.writeBashBin "build" (
              import ./commands/build.nix {
                commands = commands;
              }
            );
            build-addons = pkgs.writers.writeBashBin "build-addons" (
              import ./commands/build-addons.nix {
                config = config;
                lib = lib;
              }
            );
            build-config = pkgs.writers.writeBashBin "build-config" (
              import ./commands/build-config.nix {
                config = completeConfig;
                lib = lib;
              }
            );
            build-dev = pkgs.writers.writeBashBin "build-dev" (
              import ./commands/build-dev.nix {
                config = completeConfig;
                lib = lib;
              }
            );
            build-repos = pkgs.writers.writePython3Bin "build-repos" {
              flakeIgnore = [ "E265" "E501" ];
            } (
              import ./commands/build-repos.nix {
                config = completeConfig;
                lib = lib;
                pkgs = pkgs;
              }
            );
            build-venv = pkgs.writers.writeBashBin "build-venv" (
              import ./commands/build-venv.nix {
                config = completeConfig;
                lib = lib;
                odooMajorVersion = odooMajorVersion;
                pkgs = pkgs;
                python = python;
              }
            );
            run = pkgs.writers.writeBashBin "run" (
              import ./commands/run.nix {
                odooMajorVersion = odooMajorVersion;
              }
            );
            shell = pkgs.writers.writeBashBin "shell" (
              import ./commands/shell.nix {
                odooMajorVersion = odooMajorVersion;
              }
            );
          };
        in
        pkgs.mkShell {
          packages =
            with commands;
            [
              build
              build-addons
              build-config
              build-dev
              build-repos
              build-venv
              run
              shell
            ]
            ++ (with pkgs; [
              cyrus_sasl
              stdenv.cc.cc.lib
              git-aggregator
              libffi
              libjpeg
              libxcrypt-legacy
              libxml2
              libxslt
              openldap
              pkg-config
              postgresql_17.dev
              python.package
              wget
              wkhtmltopdf
              yq
              zlib
            ]);

          shellHook = with pkgs; ''
            alias python="${python.package}/bin/python${lib.versions.majorMinor python.version}"
            export PYTHONPATH="${python.package}/lib/site-packages"
            # Python 3.6 may fail if this environment variable is set to something
            unset _PYTHON_SYSCONFIGDATA_NAME
            export LD_LIBRARY_PATH=\
            "${stdenv.cc.cc.lib}/lib:"\
            "${libxcrypt-legacy}/lib"

            if [ -f wax/venv/bin/activate ]; then
              . wax/venv/bin/activate
            fi
          '';
        };

    };
}
