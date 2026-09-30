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
    cargoRoot = "src/rust";
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
    nativeBuildInputs = [
      common.zope-event
      common.zope-interface
    ];
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

  libsass = pythonPackage {
    pname = "libsass";
    version = "0.20.1";
    hash = "sha256-4OYINuzL8tniTsl4qAXNZkL6klFfvZXjST/uJ2r3b4o=";
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

  passlib = pythonPackage {
    pname = "passlib";
    version = "1.7.4";
    hash = "sha256-3v1Q9ytlxUAqssVzgwppeOXyAq0NmEeTyN3ixBUuvgQ=";
  };

  psutil = pythonPackage {
    pname = "psutil";
    version = "5.8.0";
    hash = "sha256-DJzLmat2Al8vC77PNB1GVunBNR24zIoDzNYuMYq0tcY=";
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

  python-stdnum = pythonPackage {
    pname = "python-stdnum";
    version = "1.16";
    hash = "sha256-QkjYmAQqgB/E7/lvv+S/Y6QzJIVO/jtVNHGMHBlcb0M=";
  };

  xlrd = pythonPackage {
    pname = "xlrd";
    version = "1.2.0";
    hash = "sha256-VG6zbO6NtAw+qkbDUeZ//ubutfomULcbxMdYopobKbI=";
  };

  zeep = pythonPackage {
    pname = "zeep";
    version = "4.0.0";
    hash = "sha256-mBWOQ9szc51BUCoafjYp3LYt/Qhk6ijJ1D9WCgkc/j8=";
  };
}
