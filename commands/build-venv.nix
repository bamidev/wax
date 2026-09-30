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

  # Create the virtual environment
  PYTHON="python${lib.versions.majorMinor python.version}"
  PYTHON_FULL="${python.package}/bin/$PYTHON"
  VENV_PYTHON="wax/venv/bin/$PYTHON"

  # Provide some compiler flags to help the required python packages to be compiled.
  # Perhaps older versions of python or pip doesn't use pkg-config.
  export CFLAGS="$CFLAGS "\
  "$(pkg-config --cflags libjpeg) "\
  "$(pkg-config --cflags libxml-2.0) "\
  "$(pkg-config --cflags libxslt) "\
  "$(pkg-config --cflags libxcrypt) "\
  "$(pkg-config --cflags zlib)"
    export LDFLAGS="$LDFLAGS "\
  "$(pkg-config --libs-only-L libjpeg) "\
  "$(pkg-config --libs-only-L lber) "\
  "$(pkg-config --libs-only-L ldap) "\
  "$(pkg-config --libs-only-L libxml-2.0) "\
  "$(pkg-config --libs-only-L libxslt) "\
  "$(pkg-config --libs-only-L libxcrypt) "\
  "$(pkg-config --libs-only-L zlib)"
  if [ ${toString odooMajorVersion} -lt 13 ]; then
    export CFLAGS="$CFLAGS "\
  "-I${cyrus_sasl.dev}/include/sasl"
    export LDFLAGS="$LDFLAGS "\
  "-L${cyrus_sasl}/lib"
  fi
  if [ ${toString odooMajorVersion} -lt 19 ]; then
    export LDFLAGS="$LDFLAGS "\
  "-L$(pwd)/wax/venv/lib"
  fi

  if [ ! -e wax/venv ]; then
    mkdir -p wax/tmp
    if [ ${lib.versions.major python.version} == 2 ]; then
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
