{
  devPythonPackages,
  lib,
  python,
}:
let
  pythonMajorMinor = lib.versions.majorMinor python.version;
  sitePackagesSubpath = "lib/python${pythonMajorMinor}/site-packages";
  venvSitePackages = "wax/venv/${sitePackagesSubpath}";

  packages = builtins.attrValues devPythonPackages;
in
''
  #!/usr/bin/env bash
  set -ex
''
+ lib.concatMapStringsSep "\n" (
  # cp -r (not a flat `ln -sf pkg/site-packages/* dest/`, same reasoning as build-venv.nix): merges
  # into any directory that already exists at the destination (needed for namespace packages, and
  # for adding these dev packages on top of whatever build-venv already populated) rather than
  # replacing it outright. chmod afterwards because cp sets any directory *it* creates to match the
  # source's permissions, which in the nix store is read-only - otherwise the next package copied
  # in here would get "Permission denied" trying to add more files to that same directory.
  pkg: ''
    cp -r --no-clobber ${pkg}/${sitePackagesSubpath}/. "${venvSitePackages}/"
    chmod -R u+w "${venvSitePackages}"
  '') packages
+ ''

  # Make the local Odoo checkout (cloned by build-repos into wax/repos/odoo) importable from the
  # venv, the same way `pip install -e` would: a .pth file just adds a path to sys.path at
  # interpreter startup, no copying needed - so edits made to the checkout are picked up
  # immediately by dev tooling (pylsp, pylint-odoo, mypy, ...) run through the venv's python.
  echo "$(realpath wax/repos/odoo)" > "${venvSitePackages}/odoo.pth"
''
