{
  pkgs,
  lib,
  odooMajorVersion,
}:
lib.makeOverridable
  (
    {
      pkgs,
      lib,
      odooMajorVersion,
      # Overrides the OpenSSL package the interpreter is built against (and that Odoo dependencies
      # needing to match the interpreter, e.g. cryptography, are built against too). Defaults to
      # whichever version each Odoo major needs; see the opensslPackage definition below.
      opensslPackage ? null,
    }:
    let
      opensslPackageOverride = opensslPackage;
      self = rec {
        version =
          if odooMajorVersion < 11 then
            "2.7.18"
          else if odooMajorVersion < 13 then
            "3.5.10"
          else if odooMajorVersion < 15 then
            "3.6.15"
          else if odooMajorVersion < 17 then
            "3.7.17"
          else if odooMajorVersion < 20 then
            "3.10.15"
          else
            "3.12.14";
        majorVersion = lib.strings.toInt (lib.versions.major version);
        minorVersion = lib.strings.toInt (lib.versions.minor version);

        # Odoo 15-18 all pin some version of cryptography, and every version we've hit so far needs
        # openssl 1.1, not 3.x: 2.6.1 (odoo 15, python 3.7) predates OpenSSL 3.x's API changes and
        # fails to even compile against it; 3.4.8 (odoo 16-18, python 3.7/3.10) compiles fine but
        # calls FIPS_mode(), a real OpenSSL 1.1 function whose symbol is gone from OpenSSL 3.x's
        # compiled libcrypto, so it links but fails at import time. Since distutils bakes the
        # interpreter's own build-time openssl include/lib paths into every C extension it later
        # builds (ahead of anything a package's own buildInputs adds), the interpreter itself has to
        # be built against openssl_1_1, not just the individual python package.
        #
        # Can be overridden, e.g. `python.override { opensslPackage = pkgs.openssl; }`, if you'd
        # rather take the risk of a mismatched OpenSSL than depend on the insecure, EOL 1.1 branch.
        # Note the pinned cryptography version for the affected Odoo majors will then fail to build
        # or import (see above) unless you also override it via `pythonPackageOverrides`.
        opensslPackage =
          if opensslPackageOverride != null then
            opensslPackageOverride
          else if
            builtins.elem (lib.versions.majorMinor version) [
              "3.7"
              "3.10"
            ]
          then
            pkgs.openssl_1_1
          else
            pkgs.openssl;

        package = pkgs.stdenv.mkDerivation (finalAttrs: rec {
          pname = "python";
          version = self.version;
          src = pkgs.fetchurl {
            url = "https://www.python.org/ftp/python/${finalAttrs.version}/Python-${finalAttrs.version}.tar.xz";
            hash =
              if finalAttrs.version == "2.7.18" then
                "sha256-tiwOeTdVHQzAK4/Vyw9UT5QFuvyaVNOAjtRZSBLt70M="
              else if finalAttrs.version == "3.5.10" then
                "sha256-Dw+oaFwdwfHaywtOd3l5a5Cu+Z3B+klnpxudp7V9Sig="
              else if finalAttrs.version == "3.6.15" then
                "sha256-bijXzdbdUT3RkOSbyjly4g/PRVCQzPLvPxoidhQTXZE="
              else if finalAttrs.version == "3.7.17" then
                "sha256-eREFHtBCL9VLj1n/wDD3zyrjDg9hvaGRgAuwQNzk+dI="
              else if finalAttrs.version == "3.10.15" then
                "sha256-qrCVCBdzUXJgGHmHLZN8HkkopXxAmuAjaew9kdzOvnk="
              else if finalAttrs.version == "3.12.14" then
                "sha256-XIRir1eQuvQ6MhoVWdvg2wbRvkMA+4X7U8QAYGaOVIo="
              else
                lib.fakeHash;
          };
          buildInputs = with pkgs; [
            bzip2
            cyrus_sasl
            libffi
            libxcrypt-legacy
            ncurses
            openldap
            opensslPackage
            pkg-config
            readline
            zlib
          ];
          configureFlags = [
            "--with-openssl=${opensslPackage.dev}"
            "--with-pkg-config=yes"
            # Without a shared libpython, abi3 (stable-ABI) extension modules built with pyo3/maturin
            # (e.g. cryptography on odoo 20+) crash on import with "PyInterpreterState_Get: the
            # function must be called with the GIL held" - confirmed via a minimal pyo3 extension that
            # crashed identically against a non-shared build but worked fine once built with this flag.
            "--enable-shared"
          ];
          preConfigure = with pkgs; ''
            export CPPFLAGS="-I${zlib.dev}/include -I${libffi.dev}/include "\
            "-I${readline.dev}/include "\
            "-I${bzip2.dev}/include -I${opensslPackage.dev}/include";
            export CXXFLAGS="$CPPFLAGS";
            export CFLAGS="-I${opensslPackage.dev}/include";
            export LDFLAGS="-L${zlib.out}/lib -L${libffi.out}/lib -L${readline.out}/lib -L${bzip2.out}/lib -L${opensslPackage.out}/lib";
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

        setuptoolsVersion =
          if majorVersion == 3 then
            if minorVersion <= 5 then
              "50.3.2"
            else if minorVersion <= 6 then
              "59.6.0"
            else if minorVersion <= 7 then
              "67.8.0"
            else if minorVersion <= 10 then
              # Since setuptools v82, the pkg_resources module has been removed, which causes build
              # issues with package cbor2 v5.4.2
              "81.0.0"
            else
              "84.0.0"
          else
            "44.1.1";

        buildPythonPackage = import ./packages/build.nix {
          inherit pkgs lib;
          python = {
            inherit version package;
          };
        };

        # Curried so callers apply it to pythonDefaultPackages once (`pythonPackage =
        # python.pythonPackage pythonDefaultPackages;`) and then use the resulting function like
        # buildPythonPackage itself, without repeating the basePackages boilerplate in every odoo/N.nix.
        pythonPackage =
          pythonDefaultPackages: attrs:
          buildPythonPackage (
            attrs
            // {
              nativeBuildInputs =
                (attrs.nativeBuildInputs or [ ])
                ++ builtins.attrValues pythonDefaultPackages
                ++ (with pkgs; [
                  pkg-config
                  libxcrypt-legacy
                ]);
            }
          );
      };
    in
    self
  )
  {
    inherit pkgs lib odooMajorVersion;
  }
