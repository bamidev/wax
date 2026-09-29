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
    version = "3.4.1";
    hash = "sha256-BpWUg30DdqG6z1zEKqmhvi4cE5bcYvfQf3NYr+zTSt8=";
    nativeBuildInputs = with pkgs; [
      libxml2
      libxslt
    ];
  };

  mako = pythonPackage {
    pname = "Mako";
    version = "1.0.1";
    hash = "sha256-RfCGn+vqWdq379JW+0UcN3y7eUe+84b/C7RGJ8MajRw=";
  };

  mock = pythonPackage {
    pname = "mock";
    version = "1.0.1";
    hash = "sha256-uDndLZwRfHAUMMFJlWkYpCOphjtIsJyQ4wpgE+fS9E8=";
  };

  ofxparse = pythonPackage {
    pname = "ofxparse";
    version = "0.14";
    hash = "sha256-2MSGEmqU2RJELQQBIdtE+8SmRupw+pNd8ztbTb+75Co=";
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
    version = "2.2.0";
    hash = "sha256-sVzJ58rQmRvRy4BvqQ6oW6OpXQ8SJmJezvmTKUrWFSE=";
  };

  pydot = pythonPackage {
    pname = "pydot";
    version = "1.0.2";
    hash = "sha256-gOoBp7p1Zxo7eJA3W+CtjVMhsHv7b1chksMUCQYrWfM=";
  };

  pyparsing = pythonPackage {
    pname = "pyparsing";
    version = "2.0.3";
    hash = "sha256-Bucp4cv1J0cDsfR7YTXtgzWZnVR/nYzwSLIQ+46/hE8=";
  };

  pyserial = pythonPackage {
    pname = "pyserial";
    version = "2.7";
    hash = "sha256-NULsCDh5PmHWIk4n/wXozkulpcXMTsXGo+jUkkeYVHc=";
  };

  python-dateutil = pythonPackage {
    pname = "python-dateutil";
    version = "2.4.0";
    hash = "sha256-Q53zPOR+8UeKT0dl8zkOqw7T7ErhC+MvKTAADI0Z9Bc=";
  };

  python-ldap = pythonPackage {
    pname = "python-ldap";
    version = "2.4.19";
    hash = "sha256-Av3bOsy/tU5A/0ellFfkIrJT+fts1kuzhRs0kpX6sEg=";
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
    version = "2014.10";
    hash = "sha256-qUE4tjiQdJH0c8h16MlSA6agLv71K2VivjAuQ1AW9PM=";
  };

  pyusb = pythonPackage {
    pname = "pyusb";
    version = "1.0.0b2";
    hash = "sha256-FOxmB3vc1vGqnokqCjWlS7PB7FaqdA6tZDScGPAYbRk=";
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
    version = "5.1";
    hash = "sha256-M73uXoNPyZ61OOHa0ZijpbcNCoiEVinKz0xZK+HOf2o=";
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

  six = pythonPackage {
    pname = "six";
    version = "1.9.0";
    hash = "sha256-4kBSQR/E+9H2cmNVN8P8IzDZSBsYwDF2lbRiWVEskdU=";
  };

  suds-jurko = pythonPackage {
    pname = "suds-jurko";
    version = "0.6";
    extension = "zip";
    hash = "sha256-HLclLLEwGPwyiHw6g07XxmSKW1xMFZvlgG2i4XhTmeg=";
    nativeBuildInputs = [ pkgs.unzip ];
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
