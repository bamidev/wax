# Odoo 20 is the first major version on python 3.12 (odoo's requirements.txt is written around
# Ubuntu 24.04/Debian 12, which ship 3.12 - not 3.11), so (unlike 17/18, which share
# common/3.10.nix) there's nothing to consolidate into a common/ file yet - just the plain package
# set below, pinned to what odoo's own requirements.txt resolves to for python_version >= '3.12'
# (falling back to each package's latest release where the upstream file leaves that python
# version unpinned, since it otherwise expects a Debian 12 apt package instead of a pip one).
{
  config,
  pkgs,
  lib,
  python,
  pythonDefaultPackages,
}:
let
  pythonPackage = python.pythonPackage pythonDefaultPackages;
  common310 = import ./common/3.10.nix {
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
    version = "1.5.1";
    hash = "sha256-E644UCvmMhFav4oky+X02lLjtSMZkK/zESPIBTBsy5w=";
  };

  inherit (common310) attrs;

  babel = pythonPackage {
    pname = "Babel";
    version = "2.10.3";
    hash = "sha256-dhRVNxHul0kPcyEm3Ad/jQrghOvGqW4j2xSCr6vbLFE=";
  };

  # ofxparse dependency. Not in odoo's requirements.txt (a transitive dep we have to supply
  # ourselves). Modern releases (>=4.11) ship no setup.py, only a hatchling-based pyproject.toml,
  # which our setuptools-only builder can't drive - 4.10.0 is the last release with a real
  # setup.py, same version already used for python 3.7/3.10 (see common/3.7.nix, common/3.10.nix).
  beautifulsoup4 = pythonPackage {
    pname = "beautifulsoup4";
    version = "4.10.0";
    hash = "sha256-wjrSPFIdgYlVpBUaZ9gVgDGdS/VI09SfQiOuBB/5iJE=";
    nativeBuildInputs = [ soupsieve ];
    pythonImportsCheck = [ "bs4" ];
  };

  soupsieve = pythonPackage {
    pname = "soupsieve";
    version = "2.10";
    hash = "sha256-Sek4DX0pBUY1g7r+KF6BjHNmqe17Ou4iHBrHnJBdi8A=";
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail \
        $'dynamic = [\n    "classifiers",\n    "version",\n]' \
        'version = "2.10"'
    '';
  };

  inherit (common310) cached-property;

  # 6.x moved to a rust-only extension with no pure-python fallback at all (imports fail outright
  # without cargo/rustc and crates.io network access, which the sandbox blocks). 5.6.2 - the exact
  # version odoo's own requirements.txt pins for python_version >= '3.12' - still has a classic
  # setup.py building a plain C extension, gracefully falling back to pure python when it's
  # missing, and its setup.py itself checks CBOR2_BUILD_C_EXTENSION to skip building it entirely.
  # TODO: Implement the cargo backend.
  cbor2 = pythonPackage {
    pname = "cbor2";
    version = "5.6.2";
    hash = "sha256-t1E8LeqIaJkfrX74iZiQ68+LGZubRGHDwR160670gg0=";
    nativeBuildInputs = [ pythonDefaultPackages.setuptools-scm ];
    preBuild = ''
      export CBOR2_BUILD_C_EXTENSION=0
    '';
  };

  # requests / zeep dependency. Not in odoo's requirements.txt (a transitive dep we have to
  # supply ourselves).
  certifi = pythonPackage {
    pname = "certifi";
    version = "2024.8.30";
    hash = "sha256-vslB0qqBleJIpgsx/58FWChM8BpSWRztpz6pr//Wn9k=";
  };

  chardet = pythonPackage {
    pname = "chardet";
    version = "5.2.0";
    hash = "sha256-Gztv9HmoxBS8P6LAhSmVaVxKAm3NbQYzst0JLKOcHPc=";
  };

  # cryptography dropped its setup.py/cffi-fallback build entirely a while back (that's what let
  # odoo 15-19 get away with CRYPTOGRAPHY_DONT_BUILD_RUST=1); 42.0.8 (odoo's own pin for python
  # 3.12) still builds via setuptools.build_meta + setuptools-rust though (not maturin - that's a
  # later change), with the Rust extension declared via a `[[tool.setuptools-rust.ext-modules]]`
  # pyproject.toml table (same shape as cbor2's, which we neutralize elsewhere - here we actually
  # want it built). setuptools-rust's own setuptools entry point registers that RustExtension
  # automatically before our setup()-less fallback runs, so this needs nothing beyond the normal
  # pythonPackage helper plus cargoLockFile for offline crate vendoring (see
  # build-python-package.nix). `src` has to be fetchzip (an extracted directory), not
  # fetchPypi/fetchurl, so "${src}/Cargo.lock" is a real path readable at eval time.
  #
  # Only works because python/default.nix now builds the interpreter with --enable-shared: pyo3's
  # abi3 (stable ABI) extensions crash on import against a non-shared libpython with
  # "PyInterpreterState_Get: the function must be called with the GIL held" - confirmed via a
  # minimal pyo3 hello-world extension that crashed identically until that flag was added.
  cryptography =
    let
      src = pkgs.fetchzip {
        url = "https://files.pythonhosted.org/packages/93/a7/1498799a2ea06148463a9a2c10ab2f6a921a74fb19e231b27dc412a748e2/cryptography-42.0.8.tar.gz";
        hash = "sha256-3bhfUTigsjh1aav6oOsZTE3UHRfpZsTw7/LnJWGJSxM=";
      };
    in
    pythonPackage {
      pname = "cryptography";
      version = "42.0.8";
      inherit src;
      cargoLockFile = "${src}/src/rust/Cargo.lock";
      cargoRoot = "src/rust";
      # For the openssl-sys crate to find our openssl.
      nativeBuildInputs = [ pkgs.pkg-config ];
      buildInputs = [ pkgs.openssl ];
      pythonImportsCheck = [ "cryptography" ];
    };

  docutils = pythonPackage {
    pname = "docutils";
    version = "0.20.1";
    hash = "sha256-8IpOJ2w6FYOobc4+NKuj/gTQK7ot1R7RYQYkToqSPjs=";
  };

  freezegun = pythonPackage {
    pname = "freezegun";
    version = "1.2.1";
    hash = "sha256-tMZO+ydea8aNxudxsX/+D/D5C4GipRiQQ1ULZRmSa6Q=";
  };

  inherit (common310) geoip2;

  gevent = pythonPackage {
    pname = "gevent";
    version = "24.2.1";
    hash = "sha256-Qy/Hb2gKz3zxiMLuD106tztjwfAxFMfNijTOu+WqIFY=";
    nativeBuildInputs = [
      zope-event
      zope-interface
    ];
    pythonImportsCheck = [ "gevent" ];
  };

  greenlet = pythonPackage {
    pname = "greenlet";
    version = "3.0.3";
    hash = "sha256-QzdEQjUyWVVM4zWZ2otpLVqpb4l21WfUut8mM3H75JE=";
  };

  h11 = pythonPackage {
    pname = "h11";
    version = "0.16.0";
    hash = "sha256-TjW5Vs9FeS5MqliF5p+6AL28b/r7+gIDAOVJsgjuX/E=";
  };

  idna = pythonPackage {
    pname = "idna";
    version = "3.6";
    hash = "sha256-ns270IOwZ5iuHoaty/6KsUec+GTk7jD+TkagA9Ekkco=";
  };

  # zeep dependency. Not in odoo's requirements.txt (a transitive dep we have to supply
  # ourselves).
  inherit (common310) isodate;

  jinja2 = pythonPackage {
    pname = "Jinja2";
    version = "3.1.2";
    hash = "sha256-MTUacCpAip51laj8YVD8P0O7a/fjGXcMvA2535Q36FI=";
  };

  libsass = pythonPackage {
    pname = "libsass";
    version = "0.22.0";
    hash = "sha256-OrWtGOR9tWD08MCePSjPO7GkRxEldIisKtrWn09/hCU=";
  };

  lxml = pythonPackage {
    pname = "lxml";
    version = "5.2.1";
    hash = "sha256-P3dl5pu84JBqfHTV/kbSx6dZYUcxjbwI5KJDHzBg4wY=";
    nativeBuildInputs = with pkgs; [
      libxml2
      libxslt
    ];
  };

  # lxml dependency. lxml.html.clean (used by odoo's mail body sanitization) was split out of
  # lxml itself into this separate package starting at lxml 5.2 - explicitly listed (but left
  # unpinned) in odoo's requirements.txt for python_version >= '3.12'. Its own install_requires
  # asks for lxml>=6.1.1, newer than the 5.2.1 pinned above; our builder doesn't do real
  # dependency resolution so this isn't a build-time issue, just a metadata mismatch worth noting
  # (verify the actual clean.py API still works against lxml 5.2.1 during the import sweep).
  lxml-html-clean = pythonPackage {
    pname = "lxml_html_clean";
    version = "0.4.5";
    hash = "sha256-4qTH1b7t0XzXtITYSKBXHlS6ojmk+d9VRuOsun+ZBWA=";
    nativeBuildInputs = [ lxml ];
    pythonImportsCheck = [ "lxml_html_clean" ];
  };

  markupsafe = pythonPackage {
    pname = "MarkupSafe";
    version = "2.1.5";
    hash = "sha256-0oPTeokLpMGuc/+t+ARkNcdue8Ike7tjwAvRpwnGVEs=";
  };

  num2words = pythonPackage {
    pname = "num2words";
    version = "0.5.13";
    hash = "sha256-owZHFvu/kNdcRJRQzr+8c6ahPmOyUx0JvezDqxoiCc8=";
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
    version = "3.1.2";
    hash = "sha256-pvWXdBjv87LVUA1U2dtQyCd6NoQ29OT43bG+NCKHAYQ=";
  };

  inherit (common310) passlib;

  # fetchPypi's legacy "/packages/source/<letter>/<pname>/..." URL 404s for this release (PyPI
  # retired that path for newer uploads); fetch from the real hash-bucketed URL instead.
  pillow = pythonPackage {
    pname = "Pillow";
    version = "10.2.0";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/f8/3e/32cbd0129a28686621434cbf17bb64bf1458bfb838f1f668262fefce145c/pillow-10.2.0.tar.gz";
      hash = "sha256-6H8LLHgVfhLXaGsn1jwHD9ZdmU6N2ubzKODc9KDNAH4=";
    };
    buildInputs = with pkgs; [
      zlib
      libjpeg
    ];
  };

  inherit (common310) platformdirs;

  inherit (common310) polib;

  psutil = pythonPackage {
    pname = "psutil";
    version = "5.9.8";
    hash = "sha256-a+Em4yJUht/yhqj7mgYkalJT9MfFO0depfWsk05kGUw=";
  };

  psycopg2 = pythonPackage {
    pname = "psycopg2";
    version = "2.9.9";
    hash = "sha256-0UVL3pP7HiJBZoEWlNYA50ZDDABvuwMeoG7MLqQb8VY=";
    nativeBuildInputs = [ config.database.package.dev ];
  };

  pyopenssl = pythonPackage {
    pname = "pyOpenSSL";
    version = "24.1.0";
    hash = "sha256-yr7Uv6pd+fGhbA72Sgy2Uxi1zQd6ftp9aXATHKL0Gm8=";
  };

  # python-ldap dependency. Not in odoo's requirements.txt (a transitive dep we have to supply
  # ourselves).
  inherit (common310) pyasn1;

  # python-ldap dependency:
  inherit (common310) pyasn1-modules;

  pypdf2 = pythonPackage {
    pname = "PyPDF2";
    version = "2.12.1";
    hash = "sha256-4D7xirzHXadBoKzBp3SSU0loh744zZiHvM4c7jk9pF4=";
  };

  # qrcode dependency (its PNG image factory imports "png" directly). Not in odoo's
  # requirements.txt (a transitive dep we have to supply ourselves).
  pypng = pythonPackage {
    pname = "pypng";
    version = "0.20220715.0";
    hash = "sha256-c5xDO6lvB4MV3lTA25da7lN8vD4dCuTtmqsMoeQn4sE=";
    pythonImportsCheck = [ "png" ];
  };

  inherit (common310) pyserial;

  python-dateutil = pythonPackage {
    pname = "python-dateutil";
    version = "2.8.2";
    hash = "sha256-ASPKzBYnrhnd88J6XeW9Z+5FhvvdZEDZdI+Ku0g9PoY=";
  };

  python-ldap = pythonPackage {
    pname = "python-ldap";
    version = "3.4.4";
    hash = "sha256-ftsKzOxOA3eXcF86Bcvzap/eUNCMj2fyrvmaJij6uCg=";
    buildBackend = "wheel";
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

  python-magic = pythonPackage {
    pname = "python-magic";
    version = "0.4.27";
    hash = "sha256-wboUsI5KX1wxowK3chI5aVsvDwWNElvVzh7ja52dPDs=";
  };

  python-stdnum = pythonPackage {
    pname = "python-stdnum";
    version = "1.19";
    hash = "sha256-Ez7IL1Y5DqdMGQVp6Y8vsUuGmAix1UeFcI8i0P6tiz8=";
  };

  # zeep dependency. Not in odoo's requirements.txt (a transitive dep we have to supply
  # ourselves).
  pytz = pythonPackage {
    pname = "pytz";
    version = "2025.2";
    hash = "sha256-NguePbtJognCGtYYCcf7RTZD4EiziSTHZYE1RnRugcM=";
  };

  inherit (common310) pyusb;

  qrcode = pythonPackage {
    pname = "qrcode";
    version = "7.4.2";
    hash = "sha256-ndlpRUgn4Sfb2TaWsgdHI55tVA4IKTfJDxSslbMPWEU=";
    nativeBuildInputs = [ pypng ];
    pythonImportsCheck = [ "qrcode" ];
  };

  reportlab = pythonPackage {
    pname = "reportlab";
    version = "4.1.0";
    hash = "sha256-Opn69BJpEVnAaLP/AcFTB84v0s9rhgGZQ0h04AIECoQ=";
  };

  requests = pythonPackage {
    pname = "requests";
    version = "2.31.0";
    hash = "sha256-lCxadY+Y15Dq7Ropy27vx/+w0c968Fw9J5Flbb1q0eE=";
  };

  # zeep dependency. Not in odoo's requirements.txt (a transitive dep we have to supply
  # ourselves).
  inherit (common310) requests-file;

  # zeep dependency:
  inherit (common310) requests-toolbelt;

  rjsmin = pythonPackage {
    pname = "rjsmin";
    version = "1.2.0";
    hash = "sha256-bFKf62xACYRFJJTFLdn99ZGFr+rMoq/FF0ooqzd1Ghs=";
  };

  # python-dateutil / ofxparse dependency. Not in odoo's requirements.txt (a transitive dep we
  # have to supply ourselves).
  six = pythonPackage {
    pname = "six";
    version = "1.17.0";
    hash = "sha256-/3AzXUaOfrbsZblbmdOig2VGBj9jrMUXHeNn6DSTKoE=";
  };

  urllib3 = pythonPackage {
    pname = "urllib3";
    version = "2.0.7";
    hash = "sha256-yX394fe9Q6ccjSpY42npsr9pLRM06p+crlWt19DdD4Q=";
  };

  vobject = pythonPackage {
    pname = "vobject";
    version = "0.9.6.1";
    hash = "sha256-llEq7HS5Crtx9rU4mN1/5HMAzJQBBMT3kUjwZx95AQE=";
  };

  # fetchPypi's legacy "/packages/source/<letter>/<pname>/..." URL 404s for this release (PyPI
  # retired that path for newer uploads); fetch from the real hash-bucketed URL instead.
  werkzeug = pythonPackage {
    pname = "Werkzeug";
    version = "3.0.1";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/0d/cc/ff1904eb5eb4b455e442834dabf9427331ac0fa02853bf83db817a7dd53d/werkzeug-3.0.1.tar.gz";
      hash = "sha256-UH6BHs6nKxikBJR63tSzOQ4duPgmtJTXZVDvRbs7Hcw=";
    };
  };

  xlrd = pythonPackage {
    pname = "xlrd";
    version = "2.0.1";
    hash = "sha256-9y8Uj1RELGsFa/kx28NPmG/Qw7C2taWNATya7ydNDIg=";
  };

  xlsxwriter = pythonPackage {
    pname = "XlsxWriter";
    version = "3.1.9";
    hash = "sha256-3oEL8yjGpFUPT/1rCzSXKut//PQPPShaBBNzT5tjqSk=";
  };

  zeep = pythonPackage {
    pname = "zeep";
    version = "4.2.1";
    hash = "sha256-cgk6z9sdg2DtQAhptz+/GIK5XEKH95gITELuDB/w5CU=";
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
  # unconditionally). Not in odoo's requirements.txt (a transitive dep we have to supply
  # ourselves). fetchPypi's legacy URL 404s for this release; fetch from the real
  # hash-bucketed URL instead.
  zope-event = pythonPackage {
    pname = "zope.event";
    version = "6.2";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/93/41/faa10af34d48d9cd6fa0249a1162943ad84a9590bd1a06939981e6640416/zope_event-6.2.tar.gz";
      hash = "sha256-uX1dYycGfua538vfYGremt5wmR4ZwWLoCOo55fzw+NM=";
    };
    pythonImportsCheck = [ "zope.event" ];
  };

  # gevent dependency, same as zope.event above. Its C extension build failure is caught and
  # degrades gracefully to pure python (see its setup.py's optional_build_ext), so it doesn't
  # need any special handling here.
  zope-interface = pythonPackage {
    pname = "zope.interface";
    version = "8.6";
    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/26/39/a8481b926e42c44a6fcc670904f8251469ec42edbff1ba066719ca1e7fb4/zope_interface-8.6.tar.gz";
      hash = "sha256-tA75tIc6+10N7AK40t/eHPGMcjN7YMmctzWWHgusBcA=";
    };
    pythonImportsCheck = [ "zope.interface" ];
  };
}
