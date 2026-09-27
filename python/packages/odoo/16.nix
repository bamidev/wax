{
  config,
  pkgs,
  lib,
  python,
  pythonDefaultPackages,
}:
let
  buildPythonPackage = import ../build-python-package.nix { inherit pkgs lib python; };
  basePackages =
    builtins.attrValues pythonDefaultPackages
    ++ (with pkgs; [
      pkg-config
      libxcrypt-legacy
    ]);

  pythonPackage =
    attrs:
    buildPythonPackage (
      attrs
      // {
        nativeBuildInputs = (attrs.nativeBuildInputs or [ ]) ++ basePackages;
      }
    );
in
rec {
  babel = pythonPackage {
    pname = "Babel";
    version = "2.9.1";
    hash = "sha256-vAwXb59qmUWCIw3zUKpuBbouvks6wxfqsp2b5dJ2jaA=";
  };

  # requests dependency:
  certifi = pythonPackage {
    pname = "certifi";
    version = "2024.8.30";
    hash = "sha256-vslB0qqBleJIpgsx/58FWChM8BpSWRztpz6pr//Wn9k=";
  };

  chardet = pythonPackage {
    pname = "chardet";
    version = "4.0.0";
    hash = "sha256-DW9ToV20Eg8rCMlPEefZPSyRHuEYtrMKBOw+6DEBefo=";
  };

  cryptography = pythonPackage {
    pname = "cryptography";
    version = "3.4.8";
    hash = "sha256-lMxe1M6u/L5b84yPumoh/B02W7j7gm6haI4zcLLiShw=";
    nativeBuildInputs = with pkgs; [
      cargo
      rustc
    ];
    buildInputs = [ pkgs.openssl ];
    # Building the rust extension needs network access (cargo fetching crates.io), which the nix
    # sandbox blocks. setup.py falls back to the pure cffi/OpenSSL backend when this is set.
    preBuild = ''
      export CRYPTOGRAPHY_DONT_BUILD_RUST=1
    '';
  };

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

  ebaysdk = pythonPackage {
    pname = "ebaysdk";
    version = "2.1.5";
    hash = "sha256-eEWOHqSg/H1pPCbeNjBpaWOTdn5KqWif0477+whAms0=";
  };

  freezegun = pythonPackage {
    pname = "freezegun";
    version = "0.3.15";
    hash = "sha256-4gYvLH+VzCdqg0wi8aFxeUZxdrYkzG+TbovDvlU1rRs=";
  };

  gevent = pythonPackage {
    pname = "gevent";
    version = "20.9.0";
    hash = "sha256-X21IBR0zZWHsCJlUMe5NJlrHI6ZLupnMWMPrGk1PXI0=";
  };

  greenlet = pythonPackage {
    pname = "greenlet";
    version = "0.4.17";
    hash = "sha256-QdiDXGmnjecY5GbdDmv9S0YSXyGmfD/2122NgFmGjWs=";
  };

  idna = pythonPackage {
    pname = "idna";
    version = "2.10";
    hash = "sha256-sweHL4VbGGMs4MIcXkW+eMDqeuTBXIKMIHiLJpIes/Y=";
  };

  jinja2 = pythonPackage {
    pname = "Jinja2";
    version = "2.11.3";
    hash = "sha256-ptWEM94K6AA0fKsfowQ867q+i6qdKeZo8cdoy4ejM8Y=";
  };

  libsass = pythonPackage {
    pname = "libsass";
    version = "0.20.1";
    hash = "sha256-4OYINuzL8tniTsl4qAXNZkL6klFfvZXjST/uJ2r3b4o=";
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

  markupsafe = pythonPackage {
    pname = "MarkupSafe";
    version = "1.1.1";
    hash = "sha256-KYcukoOXZeVGgou3dUpoxBjZJ80GT9Rwj6uf6ci7EWs=";
  };

  num2words = pythonPackage {
    pname = "num2words";
    version = "0.5.9";
    hash = "sha256-wrnuESmfl6LGCtcWGbY0Spddv2XES3EDB3cAcGr0s3g=";
  };

  ofxparse = pythonPackage {
    pname = "ofxparse";
    version = "0.19";
    hash = "sha256-2Mgf1QiTMhBtoaLokZxBLHxnfwivBNVXynZ3AaBOCRg=";
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
    version = "5.8.0";
    hash = "sha256-DJzLmat2Al8vC77PNB1GVunBNR24zIoDzNYuMYq0tcY=";
  };

  psycopg2 = pythonPackage {
    pname = "psycopg2";
    version = "2.8.6";
    hash = "sha256-+yP2xxEHw3/WZ8tOo2Pd65NrNIu9ZEknjrksGJaZ9UM=";
    nativeBuildInputs = [ config.database.package.dev ];
  };

  pydot = pythonPackage {
    pname = "pydot";
    version = "1.4.2";
    hash = "sha256-JICBo5vLVnhN6wGJd+QoYFwcdY8QiXozn84d1yj/AH0=";
  };

  pyopenssl = pythonPackage {
    pname = "pyOpenSSL";
    version = "20.0.1";
    hash = "sha256-TCMcdZVDugJWD80kgMSNzsTa40ydp9N0fFCCJ+BiS1E=";
  };

  pypdf2 = pythonPackage {
    pname = "PyPDF2";
    version = "1.26.0";
    hash = "sha256-4o+QLy8KFgPqleviHf8xHvCb49Dw7ymj5EqTJylWQ4U=";
  };

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

  python-stdnum = pythonPackage {
    pname = "python-stdnum";
    version = "1.16";
    hash = "sha256-QkjYmAQqgB/E7/lvv+S/Y6QzJIVO/jtVNHGMHBlcb0M=";
  };

  pytz = pythonPackage {
    pname = "pytz";
    version = "2025.2";
    hash = "sha256-NguePbtJognCGtYYCcf7RTZD4EiziSTHZYE1RnRugcM=";
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
    version = "3.5.59";
    hash = "sha256-p1XMotzwIxMLA7tnFnAwGpkhV9XDFR2DjAto74mJRTY=";
  };

  requests = pythonPackage {
    pname = "requests";
    version = "2.25.1";
    hash = "sha256-J5c91KkEpPE7JjoZyGbBO5KjntHJZGVfAl8/jT11uAQ=";
  };

  # python-dateutil dependency:
  six = pythonPackage {
    pname = "six";
    version = "1.16.0";
    hash = "sha256-HmHDdHehYmRY4297HYKqXJsJT6SAKJIHLknenGDEySY=";
  };

  urllib3 = pythonPackage {
    pname = "urllib3";
    version = "1.26.5";
    hash = "sha256-p6zQl3ElMl9Ra9qXNfpxQrkJqNAeiy5MgQjQmE5uAJg=";
  };

  vobject = pythonPackage {
    pname = "vobject";
    version = "0.9.6.1";
    hash = "sha256-llEq7HS5Crtx9rU4mN1/5HMAzJQBBMT3kUjwZx95AQE=";
  };

  werkzeug = pythonPackage {
    pname = "Werkzeug";
    version = "0.16.1";
    hash = "sha256-s1OFbTfexZ1lETWfl/akskaEQuRUvRyYKY3c5TysHwQ=";
  };

  xlrd = pythonPackage {
    pname = "xlrd";
    version = "1.2.0";
    hash = "sha256-VG6zbO6NtAw+qkbDUeZ//ubutfomULcbxMdYopobKbI=";
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
    version = "4.0.0";
    hash = "sha256-mBWOQ9szc51BUCoafjYp3LYt/Qhk6ijJ1D9WCgkc/j8=";
  };
}
