{
  config,
  pkgs,
  lib,
  python,
  pythonDefaultPackages,
}:
let
  pythonPackage = python.pythonPackage pythonDefaultPackages;
  common = import ./common/${lib.versions.majorMinor python.version}.nix {
    inherit
      config
      pkgs
      lib
      python
      pythonDefaultPackages
      ;
  };
in
common
// rec {
  babel = pythonPackage {
    pname = "Babel";
    version = "1.3";
    hash = "sha256-nwLQNXGE3h8JPBABK1LnRUoQCL5qXBhat6Mwes6x0S4=";
  };

  decorator = pythonPackage {
    pname = "decorator";
    version = "3.4.0";
    hash = "sha256-wgtATLt+5c69UGaI4BFOPNdvXOIzgFpR824aeYjZ14M=";
  };

  feedparser = pythonPackage {
    pname = "feedparser";
    version = "5.1.3";
    hash = "sha256-rVQ2OeidQ2heLx07bkhxFWLuw743nmlYqSD76vTGO84=";
  };

  gdata = pythonPackage {
    pname = "gdata";
    version = "2.0.18";
    hash = "sha256-VufSLegZwisTzrD+GGlym0KH+J671LtVOA17z2Gh/bY=";
  };

  gevent = pythonPackage {
    pname = "gevent";
    version = "1.0.2";
    hash = "sha256-OuHKD1M93LF6qxbOZrQks/O4Vf87lQhSaRXTxrc/ujE=";
  };

  greenlet = pythonPackage {
    pname = "greenlet";
    version = "0.4.7";
    extension = "zip";
    hash = "sha256-8yxPpOBkQ+G9sNMraedhfCX/dyw//G0Kpj0ZLp/Xlf4=";
    # Sdist is a .zip, and stdenv's unpackPhase needs unzip on PATH to handle that.
    nativeBuildInputs = [ pkgs.unzip ];
  };

  jinja2 = pythonPackage {
    pname = "Jinja2";
    version = "2.8.1";
    hash = "sha256-NTQfOpe0Yyez7x62JKreqHpTW49QhjA24IXnxCasWJE=";
  };

  lxml = pythonPackage {
    pname = "lxml";
    version = "3.3.5";
    hash = "sha256-ataUncfup0SjD7p3qWjdWRD1RSIOWLzIE7nfXHk+MYo=";
    nativeBuildInputs = with pkgs; [
      libxml2
      libxslt
    ];
  };

  mako = pythonPackage {
    pname = "Mako";
    version = "1.0.0";
    hash = "sha256-o81yz+9QcgS1D3T/y/z95+hWQ3iR0/bP54CGaYbQBv4=";
  };

  markupsafe = pythonPackage {
    pname = "MarkupSafe";
    version = "0.23";
    hash = "sha256-pOwa/1m5WhS0XrLiN2GgF56YMZ2lp+t2tW6ozce4ccM=";
  };

  mock = pythonPackage {
    pname = "mock";
    version = "1.0.1";
    hash = "sha256-uDndLZwRfHAUMMFJlWkYpCOphjtIsJyQ4wpgE+fS9E8=";
  };

  passlib = pythonPackage {
    pname = "passlib";
    version = "1.6.2";
    hash = "sha256-6Yf2AA0WJy91MUxxR+sBVyfoUyo7dHsaj7WOFUxoOS0=";
  };

  pillow = pythonPackage {
    pname = "Pillow";
    version = "3.3.2";
    hash = "sha256-1Qw0FKnvAL8g32x9G7ZSKEmQfLGqxRIbTd0qStqfyZA=";
    buildInputs = with pkgs; [
      zlib
      libjpeg
    ];
    # This version predates Pillow's pkg-config-based dependency detection - it just scans a
    # hardcoded list of directories (/usr/include etc.) for zlib.h, none of which exist in the nix
    # sandbox, and fails before ever invoking the compiler. Feed it CFLAGS/LDFLAGS directly.
    preBuild = ''
      export CFLAGS="-I${pkgs.zlib.dev}/include -I${pkgs.libjpeg.dev}/include $CFLAGS"
      export LDFLAGS="-L${pkgs.zlib.out}/lib -L${pkgs.libjpeg.out}/lib $LDFLAGS"
    '';
  };

  psutil = pythonPackage {
    pname = "psutil";
    version = "2.1.1";
    hash = "sha256-v4EqSqakEUfQ6W5j2CbrdYL9prVK2PIlNDVLf4rEVZM=";
  };

  pydot = pythonPackage {
    pname = "pydot";
    version = "1.0.2";
    hash = "sha256-gOoBp7p1Zxo7eJA3W+CtjVMhsHv7b1chksMUCQYrWfM=";
  };

  pyparsing = pythonPackage {
    pname = "pyparsing";
    version = "1.5.7";
    hash = "sha256-ZG4U+Qs2ibAFwZrJtrOQyaOb+XZIGEmZPid9c4Dm558=";
  };

  pyserial = pythonPackage {
    pname = "pyserial";
    version = "2.7";
    hash = "sha256-NULsCDh5PmHWIk4n/wXozkulpcXMTsXGo+jUkkeYVHc=";
  };

  python-dateutil = pythonPackage {
    pname = "python-dateutil";
    version = "1.5";
    hash = "sha256-bxlzSLRvuM358/z8Kn1al9qV2z4uhmfPZXIWJ0/hsAk=";
  };

  python-ldap = pythonPackage {
    pname = "python-ldap";
    version = "2.4.15";
    hash = "sha256-MLysM97ZQ1V/uvsbbZw0XeqzTYnWPbzunmtZIH2xFnA=";
    nativeBuildInputs = with pkgs; [
      cyrus_sasl
      openldap
    ];

    preBuild = ''
      mkdir -p ldap-shim
      ln -s ${pkgs.openldap}/lib/libldap.so ldap-shim/libldap_r.so
      export NIX_LDFLAGS="-L$PWD/ldap-shim $NIX_LDFLAGS"
      export CFLAGS="-I${pkgs.cyrus_sasl.dev}/include/sasl $CFLAGS"
    '';
  };

  pytz = pythonPackage {
    pname = "pytz";
    version = "2014.4";
    hash = "sha256-/dwIG5rq1NTsCWhcbp7Wx9P1ys4f99Ocdrp3DyyNEEk=";
  };

  pyusb = pythonPackage {
    pname = "pyusb";
    version = "1.0.0b1";
    hash = "sha256-b6eHhAuqjGoEHjcL84ESeq5ftEyCC6ZV+Wa32k3mJ58=";
    pythonImportsCheck = [ "usb" ];
  };

  pyyaml = pythonPackage {
    pname = "PyYAML";
    version = "3.11";
    hash = "sha256-w2yTiocuX/SUk4szsUqqFWy0OexnVI/Ks1Nbt4sIRug=";
    pythonImportsCheck = [ "yaml" ];
  };

  qrcode = pythonPackage {
    pname = "qrcode";
    version = "5.0.1";
    hash = "sha256-XOFgYMLE+fyUVbyCdmwiflXum0O/ufF7/j8fW6Xuzzw=";
  };

  reportlab = pythonPackage {
    pname = "reportlab";
    version = "3.1.44";
    hash = "sha256-9sIuSv79Gu0OhfHBIW7uXnTS63fVOWP+qwFysyG2NtU=";
  };

  # requires = [] in this version's setup.py - it vendors urllib3/chardet/certifi internally, so
  # none of those need to be built separately.
  requests = pythonPackage {
    pname = "requests";
    version = "2.6.0";
    hash = "sha256-HNvtHw4jbzXvVOkZmCx6M45P6jeGMQkz06eIegS3TXU=";
  };

  simplejson = pythonPackage {
    pname = "simplejson";
    version = "3.5.3";
    hash = "sha256-qA3JAyDhwbjqzqqnVa4q7TgtZKWTIa6fbdvgMhwCh4o=";
  };

  six = pythonPackage {
    pname = "six";
    version = "1.7.3";
    hash = "sha256-eoQsn4gsCyqxBk1We7n/9qIcnvvD2Zkgg61hk3h+05M=";
  };

  unittest2 = pythonPackage {
    pname = "unittest2";
    version = "0.5.1";
    hash = "sha256-ql3ozfZU2EM3nJe9HuJA6GNW0zVal7FHpvP00UkkenE=";
  };

  vobject = pythonPackage {
    pname = "vobject";
    version = "0.6.6";
    hash = "sha256-mcAol5RiV70Dasu/N4iM9efsuDL5jWjL+cbotKWRvYY=";
  };

  werkzeug = pythonPackage {
    pname = "Werkzeug";
    version = "0.9.6";
    hash = "sha256-fxHn4uc+siZ3ysGxERPrYQb2bO3vE9FA6Dz2VjyQt5w=";
  };

  xlwt = pythonPackage {
    pname = "xlwt";
    version = "0.7.5";
    hash = "sha256-lHi9cLhlkLmsJpeWfIoQpJF9kAY2NJynPus2KjInQjw=";
  };
}
