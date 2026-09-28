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
in
rec {
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

  chardet = pythonPackage {
    pname = "chardet";
    version = "3.0.4";
    hash = "sha256-hKuS7RxNTxaRbgWQa2t1psD7XbghzGXnDL1ko+Kl6q4=";
  };

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

  ebaysdk = pythonPackage {
    pname = "ebaysdk";
    version = "2.1.5";
    hash = "sha256-eEWOHqSg/H1pPCbeNjBpaWOTdn5KqWif0477+whAms0=";
  };

  gevent = pythonPackage {
    pname = "gevent";
    version = "1.2.2";
    hash = "sha256-R5HIrpxX1vFTNUc24cyrHiuvbI2a5ad6mskPQeKWay0=";
  };

  greenlet = pythonPackage {
    pname = "greenlet";
    version = "0.4.10";
    extension = "zip";
    hash = "sha256-mpjUn2MlmxbTYnl2tp3YVoiKN2xJiwkcjp6tVtUJjKg=";
    # Sdist is a .zip, and stdenv's unpackPhase needs unzip on PATH to handle that.
    nativeBuildInputs = [ pkgs.unzip ];
  };

  # imported unconditionally by odoo/tools/mail.py at runtime, even though odoo 13's own
  # requirements don't list it (14+ does).
  idna = pythonPackage {
    pname = "idna";
    version = "2.6";
    hash = "sha256-LGpd4wiQCePafF3eZKFB28hVHVt/bPTtfCVo0MxSCo8=";
  };

  jinja2 = pythonPackage {
    pname = "Jinja2";
    version = "2.10.1";
    hash = "sha256-BlxPAuvn989VnknuWpX7gAqeRShyeuxvJEAqU3TGUBM=";
  };

  libsass = pythonPackage {
    pname = "libsass";
    version = "0.17.0";
    hash = "sha256-lT6+gQ8J2BuEzK/coPthcdG1jI8BR8tlAYSkHhJOKW8=";
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
    version = "1.0.7";
    hash = "sha256-TgL95XvUq7XsQAGB5MMU9WrD5Juk+4sNULuhjLJ9Ja4=";
  };

  markupsafe = pythonPackage {
    pname = "MarkupSafe";
    version = "1.1.0";
    hash = "sha256-TpczLJzkRLDCw43SLdxhx0PrII2RbkJloqO1db3MsdM=";
  };

  num2words = pythonPackage {
    pname = "num2words";
    version = "0.5.6";
    hash = "sha256-rqJsLRHWNvDp2glPK/VayUyxw4D/H4bo2yLCEOWmoF8=";
  };

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

  psycopg2 = pythonPackage {
    pname = "psycopg2";
    version = "2.7.7";
    hash = "sha256-9FJtB4rt1Rh9BQiqX5oB6uakikcO1nhAbalLTNZSS34=";
    nativeBuildInputs = [ config.database.package.dev ];
  };

  pydot = pythonPackage {
    pname = "pydot";
    version = "1.4.1";
    hash = "sha256-1JydTdGRO+7CqZf4MVQ8jL1T5TWxpznpIWQv5BYjXwE=";
  };

  pypdf2 = pythonPackage {
    pname = "PyPDF2";
    version = "1.26.0";
    hash = "sha256-4o+QLy8KFgPqleviHf8xHvCb49Dw7ymj5EqTJylWQ4U=";
  };

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
  six = pythonPackage {
    pname = "six";
    version = "1.16.0";
    hash = "sha256-HmHDdHehYmRY4297HYKqXJsJT6SAKJIHLknenGDEySY=";
  };

  # requests dependency:
  urllib3 = pythonPackage {
    pname = "urllib3";
    version = "1.24.3";
    hash = "sha256-I5Omlc0Sr+3Q3LJv5dUNDPJI5aZvddvYmj1OszOmGvQ=";
  };

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

  xlwt = pythonPackage {
    pname = "xlwt";
    version = "1.3.0";
    hash = "sha256-xZkScXqbKPGjwqmP1gdBAUsGsEOTbc7LwRPqqtoVbIg=";
  };

  zeep = pythonPackage {
    pname = "zeep";
    version = "3.2.0";
    hash = "sha256-5f64smHH4nHiDBkb00bYBwXVO5CvPB5vIUqhCIdv1y0=";
  };
}
