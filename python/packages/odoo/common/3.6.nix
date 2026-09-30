# Odoo python packages pinned to the exact same version (and thus hash) across every odoo major
# version that runs on python 3.6 (currently 13 and 14). Version-specific packages stay in each
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
in
{
  babel = pythonPackage {
    pname = "Babel";
    version = "2.6.0";
    hash = "sha256-jLpQ9IxSnKP6GM+B+pQDvhdtN0rE1gc4uDkSLfqqPSM=";
  };

  # requests dependency:
  certifi = pythonPackage {
    pname = "certifi";
    version = "2024.8.30";
    hash = "sha256-vslB0qqBleJIpgsx/58FWChM8BpSWRztpz6pr//Wn9k=";
  };

  inherit (common35) chardet;

  decorator = pythonPackage {
    pname = "decorator";
    version = "4.3.0";
    hash = "sha256-w576E/vetFBsR2ybO6v2pxjalD2reBHCBgBaSpVsCAw=";
  };

  docutils = pythonPackage {
    pname = "docutils";
    version = "0.14";
    hash = "sha256-UeZO8uv7Kcrh+qEzs3EBQ0luyiHFMPP3FCTXdod2QnQ=";
  };

  inherit (common35) ebaysdk;

  gevent = pythonPackage {
    pname = "gevent";
    version = "1.2.2";
    hash = "sha256-R5HIrpxX1vFTNUc24cyrHiuvbI2a5ad6mskPQeKWay0=";
  };

  inherit (common35) greenlet;

  # imported unconditionally by odoo/tools/mail.py at runtime, even though odoo 13's own
  # requirements don't list it (14+ does).
  idna = pythonPackage {
    pname = "idna";
    version = "2.6";
    hash = "sha256-LGpd4wiQCePafF3eZKFB28hVHVt/bPTtfCVo0MxSCo8=";
  };

  inherit (common35) jinja2;

  libsass = pythonPackage {
    pname = "libsass";
    version = "0.17.0";
    hash = "sha256-lT6+gQ8J2BuEzK/coPthcdG1jI8BR8tlAYSkHhJOKW8=";
  };

  inherit (common35) lxml;

  mako = pythonPackage {
    pname = "Mako";
    version = "1.0.7";
    hash = "sha256-TgL95XvUq7XsQAGB5MMU9WrD5Juk+4sNULuhjLJ9Ja4=";
  };

  markupsafe = pythonPackage {
    pname = "MarkupSafe";
    version = "1.1.0";
    hash = "sha256-TpczLJzkRLDCw43SLdxhx0PrII2RbkJloqO1db3MsdM=";
  };

  inherit (common35) num2words;

  ofxparse = pythonPackage {
    pname = "ofxparse";
    version = "0.19";
    hash = "sha256-2Mgf1QiTMhBtoaLokZxBLHxnfwivBNVXynZ3AaBOCRg=";
  };

  passlib = pythonPackage {
    pname = "passlib";
    version = "1.7.1";
    hash = "sha256-PZSPZBOMJWM2E/MDvMRxEm6uZ8BNXj9re4zmJC+GU+A=";
  };

  pillow = pythonPackage {
    pname = "Pillow";
    version = "5.4.1";
    hash = "sha256-UjNmTq36NCxjm5uZdxkNZK16yk7cUalmOU1+COfzip8=";
    buildInputs = with pkgs; [
      zlib
      libjpeg
    ];
  };

  polib = pythonPackage {
    pname = "polib";
    version = "1.1.0";
    hash = "sha256-+th9E2lhJ/+yfqCILWGC8anPil4rN6WHdRFmxR5aMyo=";
  };

  psutil = pythonPackage {
    pname = "psutil";
    version = "5.6.6";
    hash = "sha256-rSEoH3vWxXV43VORPS1EIY6eKf0lEo0Q/3gZ7xb6Ruc=";
  };

  inherit (common35) psycopg2;

  pydot = pythonPackage {
    pname = "pydot";
    version = "1.4.1";
    hash = "sha256-1JydTdGRO+7CqZf4MVQ8jL1T5TWxpznpIWQv5BYjXwE=";
  };

  inherit (common35) pypdf2;

  pyserial = pythonPackage {
    pname = "pyserial";
    version = "3.4";
    hash = "sha256-bi1AH97g6rmWz3NOZ3c6AUO5MncsqLQkUUQM/tlCxic=";
  };

  python-dateutil = pythonPackage {
    pname = "python-dateutil";
    version = "2.7.3";
    hash = "sha256-4nAB3jL2J8IjgKaIvMQ86DUEp7xdpHIgm0xw8Cgp8Lg=";
  };

  python-ldap = pythonPackage {
    pname = "python-ldap";
    version = "3.1.0";
    hash = "sha256-QZdeeUBlAsCScyxX7wwsLrMY2R6Odl+B9dSrbB23J8U=";
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

  pyusb = pythonPackage {
    pname = "pyusb";
    version = "1.0.2";
    hash = "sha256-TptyzEpCBcpk+/Hz//OaM1USFmwVGtED5VyCI6wUc2I=";
  };

  qrcode = pythonPackage {
    pname = "qrcode";
    version = "6.1";
    hash = "sha256-UFJThU9gfyq/TRYJLGHU6dURo7Q5LmC/+VemhZKwQ2k=";
  };

  reportlab = pythonPackage {
    pname = "reportlab";
    version = "3.5.13";
    hash = "sha256-YRbnUPmAGP68CN/ubfIERs+VStvPo3jSxwPVbIhkr/M=";
  };

  requests = pythonPackage {
    pname = "requests";
    version = "2.21.0";
    hash = "sha256-UCqCTzGs2ss6NbZpC1+/C8QdY6JKRcQAQ1KwJCcHWY4=";
  };

  # python-dateutil dependency:
  inherit (common35) six;

  # requests dependency:
  inherit (common35) urllib3;

  vobject = pythonPackage {
    pname = "vobject";
    version = "0.9.6.1";
    hash = "sha256-llEq7HS5Crtx9rU4mN1/5HMAzJQBBMT3kUjwZx95AQE=";
  };

  xlrd = pythonPackage {
    pname = "xlrd";
    version = "1.1.0";
    hash = "sha256-iiGIVRPm2RX+M6juX9+mdUM7YUBboT4qaeYu42go1+I=";
  };

  xlsxwriter = pythonPackage {
    pname = "XlsxWriter";
    version = "1.1.2";
    hash = "sha256-riJlig/Fueh1+pfCE9H/1hfYbcSb8Ivpnr2sgU23vzY=";
  };

  inherit (common35) xlwt;

  zeep = pythonPackage {
    pname = "zeep";
    version = "3.2.0";
    hash = "sha256-5f64smHH4nHiDBkb00bYBwXVO5CvPB5vIUqhCIdv1y0=";
  };
}
