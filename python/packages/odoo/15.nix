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
  chardet = pythonPackage {
    pname = "chardet";
    version = "3.0.4";
    hash = "sha256-hKuS7RxNTxaRbgWQa2t1psD7XbghzGXnDL1ko+Kl6q4=";
  };

  cryptography = pythonPackage {
    pname = "cryptography";
    version = "2.6.1";
    hash = "sha256-Jsghy+toP6y5ZgReIGQwMCnVcqh+5pylob9Uv1X5PKY=";
    # This version predates OpenSSL 3.x's API changes (e.g. EVP_PKEY_CTX_set_rsa_oaep_md became a
    # real function instead of a macro, and several CRYPTO_MEM_CHECK_* constants were removed), so
    # it fails to compile against nixpkgs' default openssl. python/default.nix builds the
    # interpreter itself against openssl_1_1 for odoo 15, since distutils bakes the interpreter's
    # own build-time openssl paths into every extension it compiles; this just matches that.
    buildInputs = [ pkgs.openssl_1_1 ];
  };

  freezegun = pythonPackage {
    pname = "freezegun";
    version = "0.3.11";
    hash = "sha256-6Dm0O/voFYtNYruX5jE9OfNYba9I4TFPsQg9LvF3ANo=";
  };

  gevent = pythonPackage {
    pname = "gevent";
    version = "1.5.0";
    hash = "sha256-soFCWOOz+zJ4a7c68nGtMfUeGsAfM7N0JrZsuEkbTCk=";
    nativeBuildInputs = [
      common.zope-event
      common.zope-interface
    ];
  };

  greenlet = pythonPackage {
    pname = "greenlet";
    version = "0.4.15";
    hash = "sha256-lBZEPiGTVuPDHx+RipG63y43rPKX4voT0k0cwjgPj7w=";
  };

  idna = pythonPackage {
    pname = "idna";
    version = "2.8";
    hash = "sha256-w1ez9ijPU64sTAVifsxIRVMULKIyZOWT0ye83l6cNAc=";
  };

  libsass = pythonPackage {
    pname = "libsass";
    version = "0.18.0";
    hash = "sha256-wvOGZ3UU+fx1hjEyi9MY3T6dg5rXtuJI7EU1oZG/0nE=";
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

  passlib = pythonPackage {
    pname = "passlib";
    version = "1.7.3";
    hash = "sha256-D+i4apALKIX+0Az16W8EDHq9YUltZd7EyBTkYvhJnYo=";
  };

  psutil = pythonPackage {
    pname = "psutil";
    version = "5.6.7";
    hash = "sha256-/62OsqxhRRi748C4653/2zqNLjp9XaUcW5dPtyOlxao=";
  };

  pydot = pythonPackage {
    pname = "pydot";
    version = "1.4.1";
    hash = "sha256-1JydTdGRO+7CqZf4MVQ8jL1T5TWxpznpIWQv5BYjXwE=";
  };

  pyopenssl = pythonPackage {
    pname = "pyOpenSSL";
    version = "19.0.0";
    hash = "sha256-rspmM49t4Z0apG7WNMO5rlGaZLRY+EaK7GiOfjwg8gA=";
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

  python-stdnum = pythonPackage {
    pname = "python-stdnum";
    version = "1.13";
    hash = "sha256-Eg+D0z+4uL4bKC8g3XVaiS1frPhPVPoh91u9JjMSgWA=";
  };

  xlrd = pythonPackage {
    pname = "xlrd";
    version = "1.1.0";
    hash = "sha256-iiGIVRPm2RX+M6juX9+mdUM7YUBboT4qaeYu42go1+I=";
  };

  zeep = pythonPackage {
    pname = "zeep";
    version = "3.4.0";
    hash = "sha256-DphmnP62B1YjGuGFSY+a4hswsmgXhrjeWO00w7k+Qd0=";
  };
}
