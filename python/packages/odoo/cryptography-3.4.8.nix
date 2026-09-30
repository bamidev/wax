{
  pkgs,
  python,
  pythonDefaultPackages,
}:
python.pythonPackage pythonDefaultPackages rec {
  pname = "cryptography";
  version = "3.4.8";
  src = pkgs.fetchFromGitHub {
    owner = "pyca";
    repo = "cryptography";
    rev = version;
    hash = "sha256-PQxRqc/UVfM998D9GNNGic/5DZkL4r8vFDyOwOJTZ78=";
  };

  buildInputs = [ python.opensslPackage ];
  cargoLockFile = "${src}/src/rust/Cargo.lock";
  cargoRoot = "src/rust";
  pythonImportsCheck = [ "cryptography" ];
}
