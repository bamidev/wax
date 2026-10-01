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
  set -e
''
+ lib.concatMapStringsSep "\n" (pkg: ''
  echo Copying package ${pkg.pname} v${pkg.version}...
  cp -r --no-clobber ${pkg}/${sitePackagesSubpath}/. "${venvSitePackages}/"
  chmod -R u+w "${venvSitePackages}"

  if [ -d "${pkg}/bin" ]; then
    cp -r "${pkg}/bin/"* wax/venv/bin
  fi
'') packages
+ ''

  # Make the local Odoo checkout (cloned by build-repos into wax/repos/odoo) importable from the
  # venv, the same way `pip install -e` would: a .pth file just adds a path to sys.path at
  # interpreter startup, no copying needed - so edits made to the checkout are picked up
  # immediately by dev tooling run through the venv's python.
  echo "$(realpath wax/repos/odoo)" > "${venvSitePackages}/odoo.pth"
''
