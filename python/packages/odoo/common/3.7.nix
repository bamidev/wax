# Odoo python packages pinned to the exact same version (and thus hash) across every odoo major
# version that runs on python 3.7 (currently 15 and 16). Version-specific packages stay in each
# odoo major version's own file; only import this for the packages that are truly identical.
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
in
{
  babel = pythonPackage {
    pname = "Babel";
    version = "2.9.1";
    hash = "sha256-vAwXb59qmUWCIw3zUKpuBbouvks6wxfqsp2b5dJ2jaA=";
  };

  # requests dependency:
  inherit (common36) certifi;

  decorator = pythonPackage {
    pname = "decorator";
    version = "4.4.2";
    hash = "sha256-46YvBSAXJEDKDcyCN0kxk4Ljd/N/FAoLme9F/suEv+c=";
  };

  docutils = pythonPackage {
    pname = "docutils";
    version = "0.16";
    hash = "sha256-wt46YOnn0Hvia38rAMoDCcIH4GwQD5zCqUkx/HWkePw=";
  };

  inherit (common35) ebaysdk;

  jinja2 = pythonPackage {
    pname = "Jinja2";
    version = "2.11.3";
    hash = "sha256-ptWEM94K6AA0fKsfowQ867q+i6qdKeZo8cdoy4ejM8Y=";
  };

  lxml = pythonPackage {
    pname = "lxml";
    version = "4.6.5";
    hash = "sha256-boTt7MOoL5DUTd7i7iomMNSZS4RxgW4ibSt3HNp6xMo=";
    nativeBuildInputs = with pkgs; [
      libxml2
      libxslt
    ];
  };

  inherit (common36) ofxparse;

  pillow = pythonPackage {
    pname = "Pillow";
    version = "9.0.1";
    hash = "sha256-bIvII4p9/a96dfXsWmY/QXP4w2flo5+H5yBJXh7tdfo=";
    buildInputs = with pkgs; [
      zlib
      libjpeg
    ];
  };

  inherit (common36) polib;

  psycopg2 = pythonPackage {
    pname = "psycopg2";
    version = "2.8.6";
    hash = "sha256-+yP2xxEHw3/WZ8tOo2Pd65NrNIu9ZEknjrksGJaZ9UM=";
    nativeBuildInputs = [ config.database.package.dev ];
  };

  inherit (common35) pypdf2;

  python-ldap = pythonPackage {
    pname = "python-ldap";
    version = "3.4.0";
    hash = "sha256-YEZMj8JeceD9QESaJOrkgtzQ+3/Pgj595iemUls+DRI=";
    nativeBuildInputs = with pkgs; [
      cyrus_sasl
      openldap
    ];

    preBuild = ''
      mkdir -p ldap-shim
      ln -s ${pkgs.openldap}/lib/libldap.so ldap-shim/libldap_r.so
      export NIX_LDFLAGS="-L$PWD/ldap-shim $NIX_LDFLAGS"
    '';
  };

  pytz = pythonPackage {
    pname = "pytz";
    version = "2025.2";
    hash = "sha256-NguePbtJognCGtYYCcf7RTZD4EiziSTHZYE1RnRugcM=";
  };

  inherit (common36) pyusb;

  inherit (common36) qrcode;

  reportlab = pythonPackage {
    pname = "reportlab";
    version = "3.5.59";
    hash = "sha256-p1XMotzwIxMLA7tnFnAwGpkhV9XDFR2DjAto74mJRTY=";
  };

  requests = pythonPackage {
    pname = "requests";
    version = "2.25.1";
    hash = "sha256-J5c91KkEpPE7JjoZyGbBO5KjntHJZGVfAl8/jT11uAQ=";
  };

  # python-dateutil dependency:
  inherit (common35) six;

  urllib3 = pythonPackage {
    pname = "urllib3";
    version = "1.26.5";
    hash = "sha256-p6zQl3ElMl9Ra9qXNfpxQrkJqNAeiy5MgQjQmE5uAJg=";
  };

  inherit (common36) vobject;

  werkzeug = pythonPackage {
    pname = "Werkzeug";
    version = "0.16.1";
    hash = "sha256-s1OFbTfexZ1lETWfl/akskaEQuRUvRyYKY3c5TysHwQ=";
  };

  inherit (common36) xlsxwriter;

  inherit (common35) xlwt;

  # gevent dependency (gevent.monkey.patch_all imports gevent.events, which needs this
  # unconditionally - only true from gevent 1.5.0 onward, which is why this isn't needed by any
  # odoo version older than 15).
  zope-event = pythonPackage {
    pname = "zope.event";
    version = "4.6";
    hash = "sha256-gdmIEwRvyGzEE242mP7mKKMoL5wyDbGGWMIXSSNfzoA=";
  };

  # gevent dependency, same as zope.event above.
  zope-interface = pythonPackage {
    pname = "zope.interface";
    version = "5.5.2";
    hash = "sha256-v+4fP/YhQ4GUmeNI9bin86oCWfmspeDdrnOR0Fnc5nE=";
  };
}
