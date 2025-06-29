{
  description = "A flake to manage odoo with git-aggregator and pip";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }: {
      lib.mkOdooVirtualContainerShell = { hostSystem, targetSystem, qemuTargetSystem, config }:
        let
          lib = nixpkgs.lib;

          pkgs = nixpkgs.legacyPackages.${hostSystem};
          pkgsTarget = nixpkgs.legacyPackages.${targetSystem};

          vm = pkgs.stdenv.mkDerivation rec {
            pname = "vm";
            version = "0.0.0";
            src = pkgs.fetchzip {
              url = "https://github.com/bamidev/wax-vm-image/wax-vm-image.tar.gz";
              hash = "sha256-tWxU/LANbQE32my+9AXyt3nCT7NBVfJ45CX757EMT3Q=";
            };

            buildPhase = ''
              set -ex

              rm -f vm.img
              ${pkgs.qemu_kvm}/bin/qemu-img create -f qcow2 vm.img 32G
              ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 -nographic -enable-kvm -boot d \
                -cdrom *.iso -m 4G -cpu host -smp 2 -hda vm.img
            '';

            installPhase = ''
              mv vm.img $out/vm.img
            '';
          };

          runVm = pkgs.writeScriptBin "build-vm" ''
              #!${pkgs.bash}/bin/bash
              set -e

              # Copy initial VM image if it doesn't exist yet
              mkdir -p wax
              if [ ! -f wax/vm.img ]; then
                cp ${vm.out}/vm.img wax/vm.img
              fi

              ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 -nographic -enable-kvm -boot d \
                -m 4G -cpu host -smp 2 -hda wax/vm.img
          '';
        in runVm;

      lib.mkOdooShell = { system, config }:
        let
          lib = nixpkgs.lib;
 
          defaultOdooConfig = {
            options = {
              addons_path = "./wax/addons";
              db_name = config.databaseName or "";
              dbfilter = "^" + (config.databaseName or "") + "$";
              logfile = "./wax/log/odoo.log";
            };
          };
          odooConfig = lib.attrsets.recursiveUpdate defaultOdooConfig config.odooConfig;
          odooMajorVersion = lib.strings.toInt (lib.versions.major config.odooVersion);

          pkgs = nixpkgs.legacyPackages.${system};

          pythonVersion = 
            if odooMajorVersion < 11 then
              "2.7.18"
            else if odooMajorVersion < 13 then
              "3.5.10"
            else if odooMajorVersion < 15 then
              "3.6.15"
            else if odooMajorVersion < 17 then
              "3.8.20"
            else
              "3.10.15";
          pythonMajorVersion = lib.strings.toInt (lib.versions.major pythonVersion);
          pythonMinorVersion = lib.strings.toInt (lib.versions.minor pythonVersion);

          pythonPackage = pkgs.stdenv.mkDerivation (finalAttrs: rec {
            pname = "python";
            version = pythonVersion;
            src = pkgs.fetchurl {
			  url = "https://www.python.org/ftp/python/${finalAttrs.version}/Python-${finalAttrs.version}.tar.xz";
			  hash = if finalAttrs.version == "2.7.18" then
				  "sha256-tiwOeTdVHQzAK4/Vyw9UT5QFuvyaVNOAjtRZSBLt70M="
				else if finalAttrs.version == "3.5.10" then
				  "sha256-Dw+oaFwdwfHaywtOd3l5a5Cu+Z3B+klnpxudp7V9Sig="
				else if finalAttrs.version == "3.6.15" then
				  "sha256-bijXzdbdUT3RkOSbyjly4g/PRVCQzPLvPxoidhQTXZE="
				else if finalAttrs.version == "3.8.20" then
				  "sha256-b7iacSQgHGESXAq0z39olN8zmkDAKDO/0oq012kfr7Q="
				else if finalAttrs.version == "3.10.15" then
				  "sha256-qrCVCBdzUXJgGHmHLZN8HkkopXxAmuAjaew9kdzOvnk="
				else
				  "unsupported python version";
			};
			buildInputs = with pkgs; [
			  bzip2
			  cyrus_sasl
			  libffi
			  ncurses
			  openldap
			  openssl
			  readline
			  zlib
			];
			configureFlags = with pkgs; [ "--with-openssl=${openssl.dev}" "--with-pkg-config=yes" ];
			preConfigure = with pkgs; ''
export CPPFLAGS="-I${zlib.dev}/include -I${libffi.dev}/include -I${readline.dev}/include -I${bzip2.dev}/include -I${openssl.dev}/include";
export CXXFLAGS="$CPPFLAGS";
export CFLAGS="-I${openssl.dev}/include";
export LDFLAGS="-L${zlib.out}/lib -L${libffi.out}/lib -L${readline.out}/lib -L${bzip2.out}/lib -L${openssl.out}/lib";
'';
			preBuild = preConfigure;

            # See https://bugs.python.org/issue45700
            # Credits to nixpkgs-python: https://github.com/cachix/nixpkgs-python/blob/main/flake.nix
            patches = lib.optionals (
                pythonMajorVersion == 3 && (builtins.elem pythonMinorVersion [5 6])
              ) [
              (pkgs.fetchpatch {
                url = "https://github.com/python/cpython/commit/8766cb74e186d3820db0a855.patch";
                sha256 = "IzAp3M6hpSNcbVRttzvXNDyAVK7vLesKZDEDkdYbuww=";
              })
              (pkgs.fetchpatch {
                url = "https://github.com/python/cpython/commit/f0be4bbb9b3cee876249c23f.patch";
                sha256 = "FUF7ZkkatS4ON4++pR9XJQFQLW1kKSVzSs8NAS19bDY=";
              })
            ];
		  });

          pipVersion =
            if pythonMajorVersion == 2 || pythonMinorVersion < 6 then
              "20.3.4"
            else
              if pythonMinorVersion == 6 then
                "21.3.1"
              else if pythonMinorVersion == 8 then
                "25.0.1"
              else
                "25.1.1";

		  defaultRequirements = import ./default-requirements.nix {
            lib = lib;
            odooMajorVersion = odooMajorVersion;
            pythonVersion = pythonVersion;
          };

		  envVariables = ''
DATABASE_NAME=${config.databaseName}
ODOO_VERSION=${config.odooVersion}
DEFAULT_MERGE_DEPTH=100
'';

		  commands = rec {

			setup = with pkgs; writeShellScriptBin "setup" ''
#!/usr/bin/env bash
set -e
mkdir -p {etc,wax/{addons,log,repos}}
touch etc/requirements.txt
touch etc/repos.yaml

# Create some necessary files
cat > wax/env-variables <<HEREDOC
${envVariables}
HEREDOC
cat > wax/default-requirements.txt <<HEREDOC
${defaultRequirements}
HEREDOC


# Create the virtual environment
PYTHON="python${lib.versions.majorMinor pythonVersion}"
PYTHON_FULL="${pythonPackage}/bin/$PYTHON"
VENV_PYTHON="wax/venv/bin/$PYTHON"

# Provide some compiler flags to help the required python packages to be compiled.
# Perhaps older versions of python or pip doesn't use pkg-config.
if [ ${toString odooMajorVersion} -lt 11 ]; then
  export CFLAGS="$CFLAGS "\
"$(pkg-config --cflags libjpeg) "\
"$(pkg-config --cflags libxml-2.0) "\
"$(pkg-config --cflags libxslt) "\
"$(pkg-config --cflags zlib)"
  export LDFLAGS="$LDFLAGS "\
"$(pkg-config --libs-only-L libjpeg) "\
"$(pkg-config --libs-only-L lber) "\
"$(pkg-config --libs-only-L ldap) "\
"$(pkg-config --libs-only-L libxml-2.0) "\
"$(pkg-config --libs-only-L libxslt) "\
"$(pkg-config --libs-only-L zlib)"
fi
if [ ${toString odooMajorVersion} -lt 13 ]; then
  export CFLAGS="$CFLAGS "\
"-I${cyrus_sasl.dev}/include/sasl"
  export LDFLAGS="$LDFLAGS "\
"-L${cyrus_sasl}/lib"
fi
if [ ${toString odooMajorVersion} -lt 17 ]; then
  export LDFLAGS="$LDFLAGS "\
"-L$(pwd)/wax/venv/lib"
fi


if [ ! -e wax/venv ]; then
  mkdir -p wax/tmp
  wget https://bootstrap-pypa-io.ingress.us-east-2.psfhosted.computer/virtualenv/${lib.versions.majorMinor pythonVersion}/virtualenv.pyz -O wax/tmp/virtualenv.pyz
  $PYTHON_FULL wax/tmp/virtualenv.pyz wax/venv

  # Fake the libldap_r binary to be available
  # Older versions of python-ldap require it instead of the standard version, but nix doesn't have that binary
  if [ ${toString odooMajorVersion} -lt 17 ]; then
    ln -f -s ${openldap}/lib/libldap.so wax/venv/lib/libldap_r.so
  fi

  $VENV_PYTHON -m pip install pip==${pipVersion}

  if [ -f requirements.lock ]; then
    $VENV_PYTHON -m pip install -r requirements.lock
  fi
fi

# Install the python packages into the virtual environment if no lock file is present yet 
if [ ! -f requirements.lock ]; then
  $VENV_PYTHON -m pip install -r wax/default-requirements.txt
  $VENV_PYTHON -m pip install -r etc/requirements.txt
  $VENV_PYTHON -m pip freeze > requirements.lock
  cp etc/requirements.txt wax/used-requirements.txt
else
  if [ ! -f wax/used-requirements.txt ]; then
    cp etc/requirements.txt wax/used-requirements.txt
  else
    cmp etc/requirements.txt wax/used-requirements.txt || echo The etc/requirements.txt file has been changed. Remove the lock file and run setup again to install the latest changes.
  fi
fi
'';

			build = with pkgs; writeShellScriptBin "build" ''
set -e

# Clean up tmp dir if it still exists
rm -rf wax/tmp/*

# Update repos with git-aggregator
echo Aggregating repositories...
(
  cd wax/repos
  gitaggregate -c ../../etc/repos.yaml --expand-env --env-file ../env-variables
)

# Check if the odoo repository has been configured
if [ ! -d wax/repos/odoo ]; then
  echo The odoo repository has not been configured in the etc/repos.yaml file. Please do that before running build.
  exit 1
fi

echo Linking addons...
${build-addons}/bin/build-addons
echo Generating odoo config...
${build-config}/bin/build-config
echo Done.
'';

            build-addons = with pkgs; writeShellScriptBin "build-addons" ''
              #!/usr/bin/env bash
              set -e

              link_addons() {
                for ADDON in $(ls wax/repos/$2); do
                  if [ "$(yq .$1.addons etc/repos.yaml)" == "null" ] || \
                     [ "$(yq ".$1.addons | index(\"$ADDON\")" etc/repos.yaml)" != "null" ]
                  then
                    ln -f -s "$(pwd)/wax/repos/$2/$ADDON" "wax/addons/$ADDON"
                  fi
                done
              }

              rm -r wax/addons || true
              mkdir wax/addons
			  for REPO in $(ls wax/repos); do
				if [ "$REPO" != "" ]; then
                  link_addons $REPO $REPO
				fi
			  done
              link_addons odoo odoo/addons
			'';

			build-config = with pkgs; writeShellScriptBin "build-config" ''
#!/usr/bin/env bash
set -e
cat > wax/odoo.cfg <<HEREDOC
${lib.generators.toINI {} odooConfig}
HEREDOC
'';

			run = pkgs.writeShellScriptBin "run" ''
#!/usr/bin/env bash
if [ ${toString odooMajorVersion} -lt 10 ]; then
  wax/venv/bin/python wax/repos/odoo/odoo.py -c wax/odoo.cfg ''$@
else
  wax/venv/bin/python wax/repos/odoo/odoo-bin -c wax/odoo.cfg ''$@
fi
'';

			shell = pkgs.writeShellScriptBin "shell" ''
#!/usr/bin/bash
if [ ${toString odooMajorVersion} -lt 10 ]; then
  wax/venv/bin/python wax/repos/odoo/odoo.py shell -c wax/odoo.cfg ''$@
else
  wax/venv/bin/python wax/repos/odoo/odoo-bin shell -c wax/odoo.cfg ''$@
fi
'';
          };
        in pkgs.mkShell {
          packages = with commands; [
            build
            build-addons
            build-config
            run
            setup
            shell
		  ] ++ (with pkgs; [
            cyrus_sasl
            stdenv.cc.cc.lib
            git-aggregator
            libffi
            libxml2
            libxslt
            openldap
            pkg-config
            postgresql_17.dev
            pythonPackage
            wget
            wkhtmltopdf
            yq
          # Dependencies of python packages:
          ]) ++ (lib.optionals (odooMajorVersion < 11) (with pkgs; [
            libxcrypt-legacy # psycopg2 2.8 uses it
            zlib # Pillow 3.3
            libjpeg # Pillow 3.3
          ]));

          shellHook = with pkgs; ''
alias python="${pythonPackage}/bin/python${lib.versions.majorMinor pythonVersion}"
export PYTHONPATH="${pythonPackage}/lib/site-packages"
# Python 3.6 may fail if this environment variable is set to something
unset _PYTHON_SYSCONFIGDATA_NAME
export LD_LIBRARY_PATH=\
"${stdenv.cc.cc.lib}/lib:"\
"${libxcrypt-legacy}/lib"

${commands.setup}/bin/setup
. wax/venv/bin/activate
'';
        };

    };
}
