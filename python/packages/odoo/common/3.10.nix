# Odoo python packages pinned to the exact same version (and thus hash) across every odoo major
# version that runs on python 3.10 (currently 17 and 18 - their requirements happen to be
# byte-for-byte identical, so this file covers everything and odoo/17.nix and odoo/18.nix are just
# thin re-exports of it).
{
  config,
  pkgs,
  lib,
  python,
  pythonDefaultPackages,
}:
let
  pythonPackage = python.pythonPackage pythonDefaultPackages;
  common35 = import ./3.5.nix {
    inherit
      config
      pkgs
      lib
      python
      pythonDefaultPackages
      ;
  };
  common36 = import ./3.6.nix {
    inherit
      config
      pkgs
      lib
      python
      pythonDefaultPackages
      ;
  };
  common37 = import ./3.7.nix {
    inherit
      config
      pkgs
      lib
      python
      pythonDefaultPackages
      ;
  };
in
rec {
  asn1crypto = pythonPackage {
    pname = "asn1crypto";
    version = "1.4.0";
    hash = "sha256-9PbhGUdOWOBKKxr4F+tYW0/XK92JuZhiRxK1yZvnZBw=";
  };

  # zeep dependency. Modern releases moved to a hatchling+setuptools_scm build with no setup.py;
  # 21.4.0 is the last release with a real setup.py.
  attrs = pythonPackage {
    pname = "attrs";
    version = "21.4.0";
    hash = "sha256-YmuoI0IR25joad92IwoTfExAoS1yRFxF1fW3FvB24v0=";
  };

  inherit (common37) babel;

  # cbor2's own setup.py does `from pkg_resources import parse_version`, which is exactly why
  # python/default.nix pins setuptools at 81.0.0 for this python range (pkg_resources was removed
  # in setuptools 82).
  cbor2 = pythonPackage {
    pname = "cbor2";
    version = "5.4.2";
    hash = "sha256-4oPnC1WgSf82TMXmSP3lh+TZsOh+SyZkxp5jkTXms7g=";
    nativeBuildInputs = [ pythonDefaultPackages.setuptools-scm ];
  };

  # zeep dependency:
  cached-property = pythonPackage {
    pname = "cached-property";
    version = "1.5.2";
    hash = "sha256-n6V1WDjuy7LSNMOqOQvYD706xraGkQm/wbSZ972JoTA=";
  };

  # requests dependency:
  inherit (common36) certifi;

  chardet = pythonPackage {
    pname = "chardet";
    version = "4.0.0";
    hash = "sha256-DW9ToV20Eg8rCMlPEefZPSyRHuEYtrMKBOw+6DEBefo=";
  };

  # ofxparse dependency:
  # 4.9.3 (like all earlier releases) has single-source py2 code relying on setuptools'
  # `use_2to3` to convert it for py3 at build time. That mechanism was removed from setuptools
  # entirely, and the source doesn't even parse as-is under py3 (it uses py2's `<>` operator as a
  # deliberate "you forgot to run 2to3" guard). 4.10.0 is the first release with native py3
  # source and a real setup.py, dropping that whole mechanism.
  beautifulsoup4 = pythonPackage {
    pname = "beautifulsoup4";
    version = "4.10.0";
    hash = "sha256-wjrSPFIdgYlVpBUaZ9gVgDGdS/VI09SfQiOuBB/5iJE=";
    nativeBuildInputs = [ soupsieve ];
    pythonImportsCheck = [ "bs4" ];
  };

  # beautifulsoup4 dependency:
  soupsieve = pythonPackage {
    pname = "soupsieve";
    version = "1.9.6";
    hash = "sha256-eYW6zJjDSSOkOZZ8GmAtxPHhX5I7b88CNEGE+GzH76o=";
  };

  cryptography = pythonPackage {
    pname = "cryptography";
    version = "3.4.8";
    hash = "sha256-lMxe1M6u/L5b84yPumoh/B02W7j7gm6haI4zcLLiShw=";
    nativeBuildInputs = with pkgs; [
      cargo
      rustc
    ];
    # This version's cffi/OpenSSL backend (see CRYPTOGRAPHY_DONT_BUILD_RUST below) compiles fine
    # against OpenSSL 3.x's headers, but calls FIPS_mode(), a real OpenSSL 1.1 API function whose
    # symbol is gone from OpenSSL 3.x's compiled libcrypto - so it links but fails at import time
    # with "undefined symbol: FIPS_mode". Build against whatever openssl the interpreter itself was
    # built against instead.
    buildInputs = [ python.opensslPackage ];
    # Building the rust extension needs network access (cargo fetching crates.io), which the nix
    # sandbox blocks. setup.py falls back to the pure cffi/OpenSSL backend when this is set.
    preBuild = ''
      export CRYPTOGRAPHY_DONT_BUILD_RUST=1
    '';
    pythonImportsCheck = [ "cryptography" ];
  };

  inherit (common37) decorator;

  docutils = pythonPackage {
    pname = "docutils";
    version = "0.17";
    hash = "sha256-4v/uqBeWQ1a6RHDvunwvQraw3gsE5mN4UH4+JQS7/0w=";
  };

  freezegun = pythonPackage {
    pname = "freezegun";
    version = "1.1.0";
    hash = "sha256-F3+d1Zhh2HHiekhMMzLzWm4/XRRibyv5G+N4kfGJJ/M=";
  };

  geoip2 = pythonPackage {
    pname = "geoip2";
    version = "2.9.0";
    hash = "sha256-9//p0ljnGkLPYizmNQ2XbeHQMSufL7zjl1x9g4tX7PA=";
  };

  gevent = pythonPackage {
    pname = "gevent";
    version = "21.12.0";
    hash = "sha256-9ItkV4w2e5H6eTv46qr0mVy5PIvEWGDkc7+GgHCtCU4=";
    nativeBuildInputs = [
      zope-event
      zope-interface
    ];
  };

  greenlet = pythonPackage {
    pname = "greenlet";
    version = "1.1.2";
    hash = "sha256-4w9epK4jRuYs7d6HlKVoWKZ7h43Xn333agdn41axdEo=";
  };

  idna = pythonPackage {
    pname = "idna";
    version = "2.10";
    hash = "sha256-sweHL4VbGGMs4MIcXkW+eMDqeuTBXIKMIHiLJpIes/Y=";
  };

  # zeep dependency:
  isodate = pythonPackage {
    pname = "isodate";
    version = "0.6.1";
    hash = "sha256-SMWIHefosKDWSMsCTIBi3ITnuEDtgehkx2FP08Envek=";
  };

  jinja2 = pythonPackage {
    pname = "Jinja2";
    version = "3.0.3";
    hash = "sha256-YRuyc81o87mT+r3EBk/IWMW0epc8tap5mewbpAXIfNc=";
  };

  libsass = pythonPackage {
    pname = "libsass";
    version = "0.20.1";
    hash = "sha256-4OYINuzL8tniTsl4qAXNZkL6klFfvZXjST/uJ2r3b4o=";
  };

  lxml = pythonPackage {
    pname = "lxml";
    version = "4.8.0";
    hash = "sha256-9j9i/GDmIopMqauuKCKPNeG9POZ1AT0d+4KGiNUMbiM=";
    nativeBuildInputs = with pkgs; [
      libxml2
      libxslt
    ];
  };

  markupsafe = pythonPackage {
    pname = "MarkupSafe";
    version = "2.0.1";
    hash = "sha256-WUxngH+xYjizDES99082wCzfItHIzake+KDtjav1Ygo=";
  };

  # geoip2 dependency:
  maxminddb = pythonPackage {
    pname = "maxminddb";
    version = "2.2.0";
    hash = "sha256-43cH7E+rEVgEZw4Pt67bS1cHWotvgAUr3GSNPABRhOU=";
  };

  num2words = pythonPackage {
    pname = "num2words";
    version = "0.5.10";
    hash = "sha256-N81PYGePfhBFzcOt9qz5PItBv3MtqGD5fTAfBOYRzFc=";
  };

  ofxparse = pythonPackage {
    pname = "ofxparse";
    version = "0.21";
    hash = "sha256-BXq2jTEnDezk0aR2Yglqp2NBloqu4UX/xxHLRMvVxKc=";
    nativeBuildInputs = [
      beautifulsoup4
      six
    ];
    pythonImportsCheck = [ "ofxparse" ];
  };

  openpyxl = pythonPackage {
    pname = "openpyxl";
    version = "3.0.9";
    hash = "sha256-QPVouYKb+eRGrP/84wJQrB+jkDUSTVX8AkAlxBSByQ8=";
  };

  passlib = pythonPackage {
    pname = "passlib";
    version = "1.7.4";
    hash = "sha256-3v1Q9ytlxUAqssVzgwppeOXyAq0NmEeTyN3ixBUuvgQ=";
  };

  pillow = pythonPackage {
    pname = "Pillow";
    version = "9.0.1";
    hash = "sha256-bIvII4p9/a96dfXsWmY/QXP4w2flo5+H5yBJXh7tdfo=";
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = with pkgs; [
      zlib
      libjpeg
    ];
  };

  # zeep dependency. Ships no setup.py, only a dynamic [project] table (hatch-vcs). Only `version`
  # is dynamic here though, so pinning just that (same technique as `packaging` elsewhere) is
  # enough for our setup.py-less fallback to read the rest of the table directly.
  platformdirs = pythonPackage {
    pname = "platformdirs";
    version = "4.2.0";
    hash = "sha256-7wzHMd9xECLBdFQ8twqbW9IuWpM3yGJO8sLOuN2th2g=";
    # Also has to drop the old-style "License :: OSI Approved :: MIT License" classifier: its
    # pyproject.toml declares both that and a PEP 639 `license = "MIT"` expression, a combination
    # setuptools 81 rejects outright (classifiers are superseded by license expressions).
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail $'dynamic = [\n  "version",\n]' 'version = "4.2.0"' \
        --replace-fail '"License :: OSI Approved :: MIT License",' ""
    '';
  };

  polib = pythonPackage {
    pname = "polib";
    version = "1.1.1";
    hash = "sha256-4Cw1WuXgVJEuOw0W/rxWUQ7/fknWC/Iq7LRjvS8qLfo=";
  };

  psutil = pythonPackage {
    pname = "psutil";
    version = "5.9.0";
    hash = "sha256-hphC29ZruAwyFxWOYp1vzq7MOjFm09H67lFbBd0myiU=";
  };

  psycopg2 = pythonPackage {
    pname = "psycopg2";
    version = "2.9.2";
    hash = "sha256-qE2p+okYSOAnDo4E3MoHO8kEZEHutHBp9cDjZ4Peu+o=";
    nativeBuildInputs = [ config.database.package.dev ];
  };

  pyopenssl = pythonPackage {
    pname = "pyOpenSSL";
    version = "21.0.0";
    hash = "sha256-Xi2MXkbQ2GWukzvvUjAJC9r1UGKB6e7GD6JQ7oBgDLM=";
  };

  # python-ldap dependency:
  pyasn1 = pythonPackage {
    pname = "pyasn1";
    version = "0.5.1";
    hash = "sha256-bTkaluWbIxMKXPp01v1/OI274mzI8e3zn93fCNnWZ2w=";
  };

  # python-ldap dependency:
  pyasn1-modules = pythonPackage {
    pname = "pyasn1_modules";
    version = "0.3.0";
    hash = "sha256-W9AURrc2650xUSow1GwawzldZ2xvPK+kwD61S5klYxw=";
    nativeBuildInputs = [ pyasn1 ];
  };

  inherit (common35) pypdf2;

  pyserial = pythonPackage {
    pname = "pyserial";
    version = "3.5";
    hash = "sha256-PHfgFBcN//vYFub/wgXphC77EL6fWOwW0+hnW0klzds=";
  };

  python-dateutil = pythonPackage {
    pname = "python-dateutil";
    version = "2.8.1";
    hash = "sha256-c+v+nb8i6DIoba+mBHPkzSOfhZL2mapa2vEAUObhgjw=";
  };

  python-ldap = pythonPackage {
    pname = "python-ldap";
    version = "3.4.0";
    hash = "sha256-YEZMj8JeceD9QESaJOrkgtzQ+3/Pgj595iemUls+DRI=";
    nativeBuildInputs =
      with pkgs;
      [
        cyrus_sasl
        openldap
      ]
      ++ [
        pyasn1
        pyasn1-modules
      ];

    preBuild = ''
      mkdir -p ldap-shim
      ln -s ${pkgs.openldap}/lib/libldap.so ldap-shim/libldap_r.so
      export NIX_LDFLAGS="-L$PWD/ldap-shim $NIX_LDFLAGS"
    '';
    pythonImportsCheck = [ "ldap" ];
  };

  python-stdnum = pythonPackage {
    pname = "python-stdnum";
    version = "1.17";
    hash = "sha256-N04rXhORLM2/ULCyP8osPgUxF0gFwy104UXzd1Yyg0A=";
  };

  inherit (common37) pytz;

  pyusb = pythonPackage {
    pname = "pyusb";
    version = "1.2.1";
    hash = "sha256-pMx0BKIDFEdUFkuLQJlOKEn94c//BrCEkvEv/52d57k=";
    pythonImportsCheck = [ "usb" ];
  };

  qrcode = pythonPackage {
    pname = "qrcode";
    version = "7.3.1";
    hash = "sha256-N1pv8kDKm9Qa3AcEKLXfwdz7sPJQfxrISPbN7TiVZXg=";
  };

  reportlab = pythonPackage {
    pname = "reportlab";
    version = "3.6.8";
    hash = "sha256-3HZX/LC8PkhcPIaaRN3bUtcRNWoBpFZmS3vvgnIiyYI=";
  };

  inherit (common37) requests;

  # zeep dependency:
  requests-file = pythonPackage {
    pname = "requests-file";
    version = "1.5.1";
    hash = "sha256-B9dCCNM4nQHDirie9AOvDP7GOVfVOgCB2OynONAkfY4=";
  };

  # zeep dependency:
  requests-toolbelt = pythonPackage {
    pname = "requests-toolbelt";
    version = "1.0.0";
    hash = "sha256-doGgo9BHAStb3A7jfX+PB+vnarCMrsz8OSHOI8iNW8Y=";
  };

  rjsmin = pythonPackage {
    pname = "rjsmin";
    version = "1.1.0";
    hash = "sha256-sV3HXHH2XZSTqMf6Iz/c7II+PxuIrYSoQ//vSbM4rDI=";
  };

  # python-dateutil dependency:
  inherit (common35) six;

  inherit (common37) urllib3;

  inherit (common36) vobject;

  werkzeug = pythonPackage {
    pname = "Werkzeug";
    version = "2.0.2";
    hash = "sha256-qiu2/I3ujWxQTArB5/X33FgQqZA+eTtvcVqfAVva25o=";
  };

  xlrd = pythonPackage {
    pname = "xlrd";
    version = "1.2.0";
    hash = "sha256-VG6zbO6NtAw+qkbDUeZ//ubutfomULcbxMdYopobKbI=";
  };

  xlsxwriter = pythonPackage {
    pname = "XlsxWriter";
    version = "3.0.2";
    hash = "sha256-UwBfA+jrWPBh6/QdV2fHSV7gdywjlv4mt+DKIvqcJXA=";
  };

  inherit (common35) xlwt;

  zeep = pythonPackage {
    pname = "zeep";
    version = "4.1.0";
    hash = "sha256-WGfy6t1rAo2XUfQVWvWQ06r5KA46DtXhWlM0OSHJVuU=";
    nativeBuildInputs = [
      attrs
      cached-property
      certifi
      chardet
      idna
      isodate
      lxml
      platformdirs
      pytz
      requests
      requests-file
      requests-toolbelt
      six
      urllib3
    ];
    pythonImportsCheck = [ "zeep" ];
  };

  # gevent dependency (gevent.monkey.patch_all imports gevent.events, which needs this
  # unconditionally).
  inherit (common37) zope-event;

  # gevent dependency, same as zope.event above.
  inherit (common37) zope-interface;
}
