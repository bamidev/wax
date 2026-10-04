{
  description = "A flake to manage Odoo setups.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    { nixpkgs, ... }:
    {
      lib.mkOdooShell =
        { system, config }:
        let
          lib = nixpkgs.lib;
          pkgs = nixpkgs.legacyPackages.${system};

          odooMajorVersion = lib.strings.toInt (lib.versions.major config.odooVersion);

          python = completeConfig.pythonOverride (
            import ./python {
              inherit pkgs lib odooMajorVersion;
            }
          );
          pythonDefaultPackages =
            import ./python/packages/python/${lib.versions.majorMinor python.version}.nix
              {
                inherit lib pkgs python;
              };
          odooPackages = import ./python/packages/odoo/${toString odooMajorVersion}.nix {
            inherit
              lib
              pkgs
              python
              pythonDefaultPackages
              ;
            config = completeConfig;
          };

          # The python packages that wll be added to the virtualenv of Wax.
          pythonPackages =
            let
              basePythonPackages = pythonDefaultPackages // odooPackages;
            in
            basePythonPackages
            // (completeConfig.pythonPackageOverrides or ({ ... }: { })) {
              prev = basePythonPackages;
              pythonPackage = python.pythonPackage pythonDefaultPackages;
            };

          # The additional packages that will be added to the virtualenv via command `setup-dev`.
          devPythonPackages =
            let
              baseDevPythonPackages = import ./python/packages/dev.nix {
                inherit
                  pkgs
                  lib
                  python
                  pythonDefaultPackages
                  odooPackages
                  odooMajorVersion
                  ;
              };
            in
            baseDevPythonPackages
            // (completeConfig.devPythonPackageOverrides or ({ ... }: { })) {
              prev = baseDevPythonPackages;
              pythonPackage = python.pythonPackage pythonDefaultPackages;
            };

          postgresContainerImage =
            if completeConfig.database.allow_containerization && completeConfig.database.name != null then
              import ./db-image.nix {
                inherit pkgs lib;
                config = completeConfig;
              }
            else
              pkgs.bash;

          defaultConfig = {
            # Lets you override the python package (e.g. to swap the OpenSSL it's built against):
            # `pythonOverride = python: python.override { opensslPackage = pkgs.openssl; };`
            pythonOverride = python: python;

            database = {
              allow_containerization = false;
              container_port = 55432;
              name = null;
              host = null;
              port = null;
              package = pkgs.postgresql_17;
              user = null;
            };

            odooConfig.options = {
              without_demo = "False"; # Install demo data by default
            }
            //
              lib.optionalAttrs
                (completeConfig.database.allow_containerization || completeConfig.database.host != null)
                {
                  db_host = if completeConfig.database.allow_containerization then "127.0.0.1" else "";
                }
            // lib.optionalAttrs (completeConfig.database.port != null) {
              db_port = completeConfig.database.port;
            }
            // lib.optionalAttrs (completeConfig.database.name != null) {
              db_name = completeConfig.database.name;
              dbfilter = "^${completeConfig.database.name}$";
            }
            //
              lib.optionalAttrs
                (completeConfig.database.allow_containerization || completeConfig.database.user != null)
                {
                  db_user =
                    if completeConfig.database.allow_containerization then "odoo" else completeConfig.database.user;
                };

            repos = {
              depth = {
                deepen = {
                  base = 250;
                  merge = 25;
                };
                initial = {
                  base = 25;
                  merge = 25;
                };
              };
              defaultRef = config.odooVersion;
              spec = { };
            };
          };
          completeConfig = lib.attrsets.recursiveUpdate defaultConfig config;

          commands = {
            build = pkgs.writers.writeBashBin "build" (
              import ./commands/build.nix {
                inherit commands;
              }
            );
            build-addons = pkgs.writers.writeBashBin "build-addons" (
              import ./commands/build-addons.nix {
                inherit lib;
                config = completeConfig;
              }
            );
            build-config = pkgs.writers.writeBashBin "build-config" (
              import ./commands/build-config.nix {
                inherit lib;
                config = completeConfig;
              }
            );
            build-dev = pkgs.writers.writeBashBin "build-dev" (
              import ./commands/build-dev.nix {
                inherit commands;
              }
            );
            build-repos =
              pkgs.writers.writePython3Bin "build-repos"
                {
                  flakeIgnore = [
                    "E265"
                    "E501"
                  ];
                }
                (
                  import ./commands/build-repos.nix {
                    inherit lib pkgs;
                    config = completeConfig;
                  }
                );
            build-venv = pkgs.writers.writeBashBin "build-venv" (
              import ./commands/build-venv.nix {
                inherit
                  lib
                  odooMajorVersion
                  pkgs
                  python
                  pythonPackages
                  ;
                config = completeConfig;
              }
            );
            db-container-shell = pkgs.writers.writeBashBin "db-container-shell" (
              builtins.readFile ./commands/db-container-shell.sh
            );
            db-shell = pkgs.writers.writeBashBin "db-shell" (
              import ./commands/db-shell.nix { config = completeConfig; }
            );
            run = pkgs.writers.writeBashBin "run" (
              import ./commands/run.nix {
                inherit odooMajorVersion pkgs;
                config = completeConfig;
              }
            );
            setup-dev = pkgs.writers.writeBashBin "setup-dev" (
              import ./commands/setup-dev.nix {
                inherit devPythonPackages lib python;
              }
            );
            shell = pkgs.writers.writeBashBin "shell" (
              import ./commands/shell.nix {
                inherit odooMajorVersion;
              }
            );
            upgrade = pkgs.writers.writeBashBin "upgrade" (
              import ./commands/upgrade.nix {
                inherit odooMajorVersion;
              }
            );
          };
        in
        pkgs.mkShell {
          packages =
            with commands;
            [
              build
              build-addons
              build-config
              build-dev
              build-repos
              build-venv
              db-container-shell
              db-shell
              run
              setup-dev
              shell
              upgrade
            ]
            ++ (with pkgs; [
              python.package
              wkhtmltopdf
            ])
            ++ [
              completeConfig.database.package.dev
            ];

          shellHook = with pkgs; ''
            # Always activate the virtualenv once it exists upon entering the shell
            if [ -f wax/venv/bin/activate ]; then
              . wax/venv/bin/activate
            fi

            # Create and start a docker container for the database, if the feature is enabled
            if [ "$WAX_CONTAINERIZED_DB" == "1" ] && [ ${toString completeConfig.database.allow_containerization} == 1 ]; then
              IMAGE_NAME=$(docker load -i ${postgresContainerImage} | awk '/Loaded image:/ {print $3}')
              IMAGE_HASH=$(basename "${postgresContainerImage}")
              export CONTAINER_ID=$(docker container ls -a -q -f "name=^wax-''${IMAGE_HASH}$")
              if [ -z "$CONTAINER_ID" ]; then
                echo Creating database container...
                export CONTAINER_ID=$(docker container create -p ${toString completeConfig.database.container_port}:5432 --name "wax-$IMAGE_HASH" "$IMAGE_NAME")
              fi

              CONTAINER_ID_RUNNING=$(docker container ls -q -f "name=^wax-''${IMAGE_HASH}$")
              if [ "$CONTAINER_ID_RUNNING" != "$CONTAINER_ID" ]; then
                echo Starting database container...
                docker start -a "$CONTAINER_ID" >> wax/log/postgres.log 2>&1 &
                trap "docker container stop '$CONTAINER_ID' && echo Stopped Postgres container." EXIT
              fi
            fi

          '';
        };

    };
}
