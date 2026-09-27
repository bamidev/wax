{
  pkgs,
  lib,
  odooMajorVersion,
}:
let
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
      else
        "3.10.15";
    majorVersion = lib.strings.toInt (lib.versions.major version);
    minorVersion = lib.strings.toInt (lib.versions.minor version);

    # Odoo 15 pins cryptography==2.6.1, which predates OpenSSL 3.x's API changes and fails to
    # compile against it. Since distutils bakes the interpreter's own build-time openssl include/
    # lib paths into every C extension it later builds (ahead of anything a package's own
    # buildInputs adds), the interpreter itself has to be built against openssl_1_1 for that case,
    # not just the individual python package.
    opensslPackage = if odooMajorVersion == 15 then pkgs.openssl_1_1 else pkgs.openssl;

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
        readline
        zlib
      ];
      configureFlags = with pkgs; [
        "--with-openssl=${opensslPackage.dev}"
        "--with-pkg-config=yes"
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
          # You can update this to the latest release of setuptools:
          "82.0.1"
      else
        "44.1.1";

    buildPythonPackage = import ./packages/build-python-package.nix {
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
