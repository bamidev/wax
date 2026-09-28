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
  mock = pythonPackage {
    pname = "mock";
    version = "2.0.0";
    hash = "sha256-sVi233bt0jm4II1IHcRrav1FqEa3gS/wzliXHPW8i7o=";
    # mock's own setup.py uses setup(pbr=True), which needs pbr present to resolve version/
    # metadata from git/PKG-INFO at build time.
    nativeBuildInputs = [ pbr ];
  };

  # mock dependency:
  pbr = pythonPackage {
    pname = "pbr";
    version = "5.11.1";
    hash = "sha256-rvxRZ1sLUz1Wu1/RyMbAUi/jGJZnmILhxMY9XkoPzLM=";
  };

  pyparsing = pythonPackage {
    pname = "pyparsing";
    version = "2.2.0";
    hash = "sha256-CDK89HrNKDeIWT56D1QkB72VUKVaioQ1IUoZYOBLywQ=";
  };

  pytz = pythonPackage {
    pname = "pytz";
    version = "2019.1";
    hash = "sha256-10fdPSPXfvRMajUm4nSvbv6wpvGv1aabpNW+QJjI4UE=";
  };

  vatnumber = pythonPackage {
    pname = "vatnumber";
    version = "1.0";
    hash = "sha256-bvYQP37PCc3zK4e7HIdha3K5VG5LNko7ZtKwtLNAZlo=";
  };

  werkzeug = pythonPackage {
    pname = "Werkzeug";
    version = "0.14.1";
    hash = "sha256-w/16fUGXbZ9E2zJyYOJjEyRmg2zvb5FRKIntYK0mVXw=";
  };
}
