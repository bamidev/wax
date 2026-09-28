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
    version = "2.3.4";
    hash = "sha256-xTXEQDgC9us4FzzUhj5BniJ0khoBqKrYpbSXwTHGKHU=";
  };

  # requests dependency:
  certifi = pythonPackage {
    pname = "certifi";
    version = "2021.10.8";
    hash = "sha256-eIhOfB1LAM486me0RWaFHENDwSCr1oNDPOk0po6liHI=";
  };

  # requests dependency (10's own requirements don't list it, but requests needs it regardless):
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

  ebaysdk = pythonPackage {
    pname = "ebaysdk";
    version = "2.1.4";
    hash = "sha256-+NdwIRMjc3pYdhadUqR3LrvGzd0GymP0n4oRCUqjP4M=";
  };

  feedparser = pythonPackage {
    pname = "feedparser";
    version = "5.2.1";
    hash = "sha256-vQMGUsLQhTLANMJ/zXyFho5/o8srF/IwpEprvJJRm/k=";
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

  jinja2 = pythonPackage {
    pname = "Jinja2";
    version = "2.10.1";
    hash = "sha256-BlxPAuvn989VnknuWpX7gAqeRShyeuxvJEAqU3TGUBM=";
  };

  # requests dependency:
  idna = pythonPackage {
    pname = "idna";
    version = "2.7";
    hash = "sha256-aEo4pvkDwdcdbV+sBmtY13aK9N4rgy5CbsecMNqpShY=";
  };

  lxml = pythonPackage {
    pname = "lxml";
    version = "3.5.0";
    hash = "sha256-NJ+T46SwnMWUGIVKuAE9An0kZ1fFF0S/IAabyJAW9Xg=";
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

  markupsafe = pythonPackage {
    pname = "MarkupSafe";
    version = "0.23";
    hash = "sha256-pOwa/1m5WhS0XrLiN2GgF56YMZ2lp+t2tW6ozce4ccM=";
  };

  mock = pythonPackage {
    pname = "mock";
    version = "2.0.0";
    hash = "sha256-sVi233bt0jm4II1IHcRrav1FqEa3gS/wzliXHPW8i7o=";
    # mock's own setup.py uses setup(pbr=True), which needs pbr present to resolve version/
    # metadata from git/PKG-INFO at build time.
    nativeBuildInputs = [ pbr ];
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
    version = "3.4.1";
    hash = "sha256-WQ7K3lfZ03O55zgWuBGyaWk/vSMTdLn1LRve4cF9m0A=";
    buildInputs = with pkgs; [
      zlib
      libjpeg
    ];
    # This version predates Pillow's pkg-config-based dependency detection - it just scans a
    # hardcoded list of directories (/usr/include etc.) for zlib.h, none of which exist in the nix
    # sandbox, and fails before ever invoking the compiler (so having zlib in buildInputs alone
    # doesn't help). Feed it CFLAGS/LDFLAGS directly instead.
    preBuild = ''
      export CFLAGS="-I${pkgs.zlib.dev}/include -I${pkgs.libjpeg.dev}/include $CFLAGS"
      export LDFLAGS="-L${pkgs.zlib.out}/lib -L${pkgs.libjpeg.out}/lib $LDFLAGS"
    '';
  };

  psutil = pythonPackage {
    pname = "psutil";
    version = "4.3.1";
    hash = "sha256-OPdBgvueFcr9DN8IIQmKlcwXMBgHrtJWNKGLZlN7pRs=";
  };

  pydot = pythonPackage {
    pname = "pydot";
    version = "1.2.3";
    hash = "sha256-7bXT8kn5f72cS7FpWeYbwy7PQO7hqfbSer6NAcCnNQI=";
  };

  pyparsing = pythonPackage {
    pname = "pyparsing";
    version = "2.1.10";
    hash = "sha256-gRw+ewAxAhE3/IPgUXlQJfy5hnTQfrj+kiuk3lPTkYg=";
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

  # Plain upstream python-ldap already supports python 2 here (the "pyldap" py3 fork used for
  # 11/12 wasn't needed until python-ldap itself lacked py3 support).
  python-ldap = pythonPackage {
    pname = "python-ldap";
    version = "2.4.27";
    hash = "sha256-Ywalejxln/2gADs4axoj/c7guQOg7eDOBMM7p4vmSi4=";
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

  pyyaml = pythonPackage {
    pname = "PyYAML";
    version = "3.12";
    hash = "sha256-WSdmxjAyB6IO/ERVh3eDItf3OxYb2ZTyJ62qNBuiEqs=";
    pythonImportsCheck = [ "yaml" ];
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
    version = "1.10.0";
    hash = "sha256-EF+NaGFvgkjiS/DpNy7wTTzBAQTxmA9U1Xss5zpa1Wo=";
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
    version = "0.11.11";
    hash = "sha256-5yxGvBRAXLp6Jr0s4o33NEcbyQFryLTLaUZsLBTC9+U=";
  };

  xlsxwriter = pythonPackage {
    pname = "XlsxWriter";
    version = "0.9.3";
    hash = "sha256-GdK1wN1NX8AOjX8WR5X1DohbINHMJ6PQTVx/7DxNV/Y=";
  };

  xlwt = pythonPackage {
    pname = "xlwt";
    version = "1.1.2";
    hash = "sha256-rtZIwXcx9A+EVQ3SoaqlNWnwy8r1YQuolc0mMlh7cjw=";
  };

  xlrd = pythonPackage {
    pname = "xlrd";
    version = "1.0.0";
    hash = "sha256-D/h91dUEJQhPchnLb4a7PrWqKQY/U9UL8nDtAH6UEGk=";
  };
}
