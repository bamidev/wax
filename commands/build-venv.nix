{
  config,
  lib,
  odooMajorVersion,
  pkgs,
  python,
  pythonPackages ? null,
}:
let
  pythonMajorMinor = lib.versions.majorMinor python.version;
  sitePackagesSubpath = "lib/python${pythonMajorMinor}/site-packages";
  venvSitePackages = "wax/venv/${sitePackagesSubpath}";
in
with pkgs;
''
  #!/usr/bin/env bash
  set -e
  mkdir -p wax/{addons,log,repos}

  PYTHON="python${lib.versions.majorMinor python.version}"
  PYTHON_FULL="${python.package}/bin/$PYTHON"

  if [ ! -e wax/venv ]; then
    if [ ${lib.versions.major python.version} == 2 ]; then
      mkdir -p wax/tmp
      wget https://bootstrap-pypa-io.ingress.us-east-2.psfhosted.computer/virtualenv/${lib.versions.majorMinor python.version}/virtualenv.pyz -O wax/tmp/virtualenv.pyz
      $PYTHON_FULL wax/tmp/virtualenv.pyz wax/venv
    else
      $PYTHON_FULL -m venv wax/venv
    fi

    # Fake the libldap_r binary to be available
    # Older versions of python-ldap require it instead of the standard version, but nix doesn't have that binary
    if [ ${toString odooMajorVersion} -lt 19 ]; then
      ln -f -s ${openldap}/lib/libldap.so wax/venv/lib/libldap_r.so
    fi

    . wax/venv/bin/activate
  fi

  if [ -e "${venvSitePackages}" ]; then
    rm -r "${venvSitePackages}/"*
  fi
''
+ lib.optionalString (pythonPackages != null) (
  lib.concatMapStringsSep "\n" (pkg: ''
    cp -r --no-clobber ${pkg}/${sitePackagesSubpath}/. "${venvSitePackages}/"
    chmod -R u+w "${venvSitePackages}"
  '') (builtins.attrValues pythonPackages)
)
+ ""
