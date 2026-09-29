# Odoo python packages pinned to the exact same version (and thus hash) across every odoo major
# version that runs on python 3.5 (currently 11 and 12). Version-specific packages stay in each
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
  common27 = import ./2.7.nix {
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
  babel = pythonPackage {
    pname = "Babel";
    version = "2.3.4";
    hash = "sha256-xTXEQDgC9us4FzzUhj5BniJ0khoBqKrYpbSXwTHGKHU=";
  };

  # requests dependency:
  certifi = pythonPackage {
    pname = "certifi";
    version = "2021.10.8";
    hash = "sha256-eIhOfB1LAM486me0RWaFHENDwSCr1oNDPOk0po6liHI=";
  };

  # requests dependency (11's own requirements don't list it, but requests needs it regardless):
  chardet = pythonPackage {
    pname = "chardet";
    version = "3.0.4";
    hash = "sha256-hKuS7RxNTxaRbgWQa2t1psD7XbghzGXnDL1ko+Kl6q4=";
  };

  decorator = pythonPackage {
    pname = "decorator";
    version = "4.0.10";
    hash = "sha256-nG6Y7cszSZiBuG7eB9mWjIGrfHaeKOmvJAdfClN58HA=";
  };

  inherit (common27) docutils;

  ebaysdk = pythonPackage {
    pname = "ebaysdk";
    version = "2.1.5";
    hash = "sha256-eEWOHqSg/H1pPCbeNjBpaWOTdn5KqWif0477+whAms0=";
  };

  gevent = pythonPackage {
    pname = "gevent";
    version = "1.1.2";
    hash = "sha256-yxXPc9aaLu7+0zCFjwljTixQv0ban552NXMPz7hywCw=";
  };

  greenlet = pythonPackage {
    pname = "greenlet";
    version = "0.4.10";
    extension = "zip";
    hash = "sha256-mpjUn2MlmxbTYnl2tp3YVoiKN2xJiwkcjp6tVtUJjKg=";
    # Sdist is a .zip, and stdenv's unpackPhase needs unzip on PATH to handle that.
    nativeBuildInputs = [ pkgs.unzip ];
  };

  html2text = pythonPackage {
    pname = "html2text";
    version = "2016.9.19";
    hash = "sha256-VU71/Wxs9uPk9yWmKj6eyGoOTTPNCSgTbRx52+t7LVU=";
  };

  # requests dependency:
  idna = pythonPackage {
    pname = "idna";
    version = "2.7";
    hash = "sha256-aEo4pvkDwdcdbV+sBmtY13aK9N4rgy5CbsecMNqpShY=";
  };

  jinja2 = pythonPackage {
    pname = "Jinja2";
    version = "2.10.1";
    hash = "sha256-BlxPAuvn989VnknuWpX7gAqeRShyeuxvJEAqU3TGUBM=";
  };

  lxml = pythonPackage {
    pname = "lxml";
    version = "3.7.1";
    hash = "sha256-HH9ncYODAHh8+huz7WUS6dx45g7LMIqO1JrJVlacHMo=";
    nativeBuildInputs = with pkgs; [
      libxml2
      libxslt
    ];
  };

  mako = pythonPackage {
    pname = "Mako";
    version = "1.0.4";
    hash = "sha256-/tmdvk0N2yejPuSRDYcIrKnvH+hU5mg4epq5qQy/kFk=";
  };

  inherit (common27) markupsafe;

  mock = pythonPackage {
    pname = "mock";
    version = "2.0.0";
    hash = "sha256-sVi233bt0jm4II1IHcRrav1FqEa3gS/wzliXHPW8i7o=";
    # mock's own setup.py uses setup(pbr=True), which needs pbr present to resolve version/
    # metadata from git/PKG-INFO at build time.
    nativeBuildInputs = [ pbr ];
  };

  num2words = pythonPackage {
    pname = "num2words";
    version = "0.5.6";
    hash = "sha256-rqJsLRHWNvDp2glPK/VayUyxw4D/H4bo2yLCEOWmoF8=";
  };

  ofxparse = pythonPackage {
    pname = "ofxparse";
    version = "0.16";
    hash = "sha256-zKg809VXjnADtTRXUixtuyeDK3NNv4aa31hfFUfDqR4=";
  };

  passlib = pythonPackage {
    pname = "passlib";
    version = "1.6.5";
    hash = "sha256-qD009T3JsXqkLJo1w/vMUSDz/LB/f4ch7EXmonvjR/w=";
  };

  # mock dependency:
  pbr = pythonPackage {
    pname = "pbr";
    version = "5.11.1";
    hash = "sha256-rvxRZ1sLUz1Wu1/RyMbAUi/jGJZnmILhxMY9XkoPzLM=";
  };

  pillow = pythonPackage {
    pname = "Pillow";
    version = "4.0.0";
    hash = "sha256-7ibS1+fjAPdrp7eWAUwEAROU0MSl7ZoogmSj5EOrylA=";
    buildInputs = with pkgs; [
      zlib
      libjpeg
    ];
  };

  psutil = pythonPackage {
    pname = "psutil";
    version = "4.3.1";
    hash = "sha256-OPdBgvueFcr9DN8IIQmKlcwXMBgHrtJWNKGLZlN7pRs=";
  };

  inherit (common27) psycopg2;

  pydot = pythonPackage {
    pname = "pydot";
    version = "1.2.3";
    hash = "sha256-7bXT8kn5f72cS7FpWeYbwy7PQO7hqfbSer6NAcCnNQI=";
  };

  # python-ldap's py3-compatible fork of that era (later merged back into python-ldap upstream).
  pyldap = pythonPackage {
    pname = "pyldap";
    version = "2.4.28";
    hash = "sha256-048xAY8MFZJfUK7Dn3JVwVRj+YeXr1OTHg4qmsIfZmE=";
    nativeBuildInputs = with pkgs; [
      cyrus_sasl
      openldap
    ];

    # Unlike newer python-ldap, this old fork's setup.py has no cyrus_sasl detection logic and
    # just does a bare #include <sasl.h>, which only exists under cyrus_sasl's include/sasl/.
    preBuild = ''
      mkdir -p ldap-shim
      ln -s ${pkgs.openldap}/lib/libldap.so ldap-shim/libldap_r.so
      export NIX_LDFLAGS="-L$PWD/ldap-shim $NIX_LDFLAGS"
      export CFLAGS="-I${pkgs.cyrus_sasl.dev}/include/sasl $CFLAGS"
    '';
  };

  pyparsing = pythonPackage {
    pname = "pyparsing";
    version = "2.1.10";
    hash = "sha256-gRw+ewAxAhE3/IPgUXlQJfy5hnTQfrj+kiuk3lPTkYg=";
  };

  pypdf2 = pythonPackage {
    pname = "PyPDF2";
    version = "1.26.0";
    hash = "sha256-4o+QLy8KFgPqleviHf8xHvCb49Dw7ymj5EqTJylWQ4U=";
  };

  pyserial = pythonPackage {
    pname = "pyserial";
    version = "3.1.1";
    hash = "sha256-1lcFEknOPL0ERrz7K+B6Q14QKdpNY/U+2bTN3nNzNkw=";
  };

  python-dateutil = pythonPackage {
    pname = "python-dateutil";
    version = "2.5.3";
    hash = "sha256-FAj9sHxqH6mZdWfOP87mozezmlA9gGmeDyE95KpLMu0=";
  };

  pytz = pythonPackage {
    pname = "pytz";
    version = "2016.7";
    hash = "sha256-h4feA/NfMWmbyvEn5WrRTABkeWXtJNctusqHxuT4Q6M=";
  };

  # PyPI's own sdist filename is capitalized "PyUSB", unlike the normalized "pyusb" project name.
  pyusb = pythonPackage {
    pname = "PyUSB";
    version = "1.0.0";
    hash = "sha256-WzT/p0rDTzML/5SclO4A7EqdFHI02xfuLu0qZ8AnU2g=";
    pythonImportsCheck = [ "usb" ];
  };

  qrcode = pythonPackage {
    pname = "qrcode";
    version = "5.3";
    hash = "sha256-QRXM7oMmIN8WtlnUZTVoMxAVxxinVIVcr1kwgF12kk4=";
  };

  reportlab = pythonPackage {
    pname = "reportlab";
    version = "3.3.0";
    hash = "sha256-9IkAuTIbyyhxpGVDmTvZlRSNdpoRqeJElfJbTsC74mc=";
  };

  requests = pythonPackage {
    pname = "requests";
    version = "2.20.0";
    hash = "sha256-mdz9qusXyvblJvMrant4BGFRKrPx2ZIYeAFpTLpCdww=";
  };

  # python-dateutil dependency:
  six = pythonPackage {
    pname = "six";
    version = "1.16.0";
    hash = "sha256-HmHDdHehYmRY4297HYKqXJsJT6SAKJIHLknenGDEySY=";
  };

  suds-jurko = pythonPackage {
    pname = "suds-jurko";
    version = "0.6";
    extension = "zip";
    hash = "sha256-HLclLLEwGPwyiHw6g07XxmSKW1xMFZvlgG2i4XhTmeg=";
    nativeBuildInputs = [ pkgs.unzip ];
  };

  # requests dependency:
  urllib3 = pythonPackage {
    pname = "urllib3";
    version = "1.24.3";
    hash = "sha256-I5Omlc0Sr+3Q3LJv5dUNDPJI5aZvddvYmj1OszOmGvQ=";
  };

  vobject = pythonPackage {
    pname = "vobject";
    version = "0.9.3";
    hash = "sha256-ELFQuH7l//79OqHqEvMaq0Wnt9AQ0c5oFq+v+NtyZSA=";
  };

  werkzeug = pythonPackage {
    pname = "Werkzeug";
    version = "0.11.15";
    hash = "sha256-RV13mKwmMmbb041IQfdTTdNcqcPaSo3zA/hIjzjzvMA=";
  };

  xlsxwriter = pythonPackage {
    pname = "XlsxWriter";
    version = "0.9.3";
    hash = "sha256-GdK1wN1NX8AOjX8WR5X1DohbINHMJ6PQTVx/7DxNV/Y=";
  };

  xlwt = pythonPackage {
    pname = "xlwt";
    version = "1.3.0";
    hash = "sha256-xZkScXqbKPGjwqmP1gdBAUsGsEOTbc7LwRPqqtoVbIg=";
  };

  xlrd = pythonPackage {
    pname = "xlrd";
    version = "1.0.0";
    hash = "sha256-D/h91dUEJQhPchnLb4a7PrWqKQY/U9UL8nDtAH6UEGk=";
  };
}
