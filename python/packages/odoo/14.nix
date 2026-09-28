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
  freezegun = pythonPackage {
    pname = "freezegun";
    version = "0.3.11";
    hash = "sha256-6Dm0O/voFYtNYruX5jE9OfNYba9I4TFPsQg9LvF3ANo=";
  };

  python-stdnum = pythonPackage {
    pname = "python-stdnum";
    version = "1.8";
    hash = "sha256-P0JjnK51wPa6c06qc5HUEbf974aIc1A/fSspYvw9cb0=";
  };

  pytz = pythonPackage {
    pname = "pytz";
    version = "2025.2";
    hash = "sha256-NguePbtJognCGtYYCcf7RTZD4EiziSTHZYE1RnRugcM=";
  };

  werkzeug = pythonPackage {
    pname = "Werkzeug";
    version = "0.16.1";
    hash = "sha256-s1OFbTfexZ1lETWfl/akskaEQuRUvRyYKY3c5TysHwQ=";
  };
}
