{
  config,
  lib,
  odooMajorVersion,
  pkgs,
  python,
}:
let
  defaultRequirements = import ../default-requirements.nix {
    odooMajorVersion = odooMajorVersion;
    pythonVersion = python.version;
  };
  envVariables = ''
    DATABASE_NAME=${config.databaseName}
    ODOO_VERSION=${config.odooVersion}
    DEFAULT_MERGE_DEPTH=100
  '';
in
with pkgs;
''
  #!/usr/bin/env bash
  set -e
  mkdir -p wax/{addons,log,repos}

  # Create some necessary files
  cat > wax/default-requirements.txt <<HEREDOC
  ${defaultRequirements}
  HEREDOC
  cat > wax/requirements.txt <<HEREDOC
  ${if config ? pythonRequirements then lib.concatStringsSep "\n" config.pythonRequirements else ""}
  HEREDOC


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
    wget https://bootstrap-pypa-io.ingress.us-east-2.psfhosted.computer/virtualenv/${lib.versions.majorMinor python.version}/virtualenv.pyz -O wax/tmp/virtualenv.pyz
    $PYTHON_FULL wax/tmp/virtualenv.pyz wax/venv

    # Fake the libldap_r binary to be available
    # Older versions of python-ldap require it instead of the standard version, but nix doesn't have that binary
    if [ ${toString odooMajorVersion} -lt 19 ]; then
      ln -f -s ${openldap}/lib/libldap.so wax/venv/lib/libldap_r.so
    fi

    . wax/venv/bin/activate
  fi

  $VENV_PYTHON -m pip install pip==${python.pipVersion}

  if [ -f requirements.lock ]; then
    $VENV_PYTHON -m pip install -r requirements.lock
  fi

  # Install the python packages into the virtual environment if no lock file is present yet
  if [ ! -f requirements.lock ]; then
    $VENV_PYTHON -m pip install -r wax/default-requirements.txt
    $VENV_PYTHON -m pip install -r wax/requirements.txt
    $VENV_PYTHON -m pip freeze > requirements.lock
    cp wax/requirements.txt wax/used-requirements.txt
  else
    if [ ! -f wax/used-requirements.txt ]; then
      cp wax/requirements.txt wax/used-requirements.txt
    else
      cmp wax/requirements.txt wax/used-requirements.txt || echo The Python requirements have \
      been changed. Remove the requirements.lock file and run setup again to install the latest \
      changes.
    fi
  fi
''
