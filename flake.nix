{
  description = "A flake to manage Odoo setups.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs =
    { self, nixpkgs }:
    {
      lib.mkOdooShell =
        { system, config }:
        let
          lib = nixpkgs.lib;
          pkgs = nixpkgs.legacyPackages.${system};

          odooMajorVersion = lib.strings.toInt (lib.versions.major config.odooVersion);

          python = import ./python {
            inherit pkgs lib odooMajorVersion;
          };
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
          pythonPackages = pythonDefaultPackages // odooPackages;

          postgresContainerImage =
            if completeConfig.database.allow_containerization then
              pkgs.dockerTools.buildImage {
                name = "wax-postgres-image";

                contents = with pkgs; [
                  bash
                  coreutils
                ];

                runAsRoot = with pkgs; ''
                  ${dockerTools.shadowSetup}
                  useradd -r postgres
                  mkdir -p /var/lib/postgresql
                  chown -R postgres /var/lib/postgresql
                  chmod 700 /var/lib/postgresql
                  mkdir -p /run/postgresql
                  chown -R postgres /run/postgresql
                '';

                config = {
                  User = "postgres";

                  Env = [
                    "PGDATA=/var/lib/postgresql"
                  ];

                  ExposedPorts = {
                    "5432/tcp" = { };
                  };

                  Cmd = [
                    "${lib.getExe pkgs.bash}"
                    "-c"
                    ''
                      set -e
                      export PATH="${completeConfig.database.package}/bin:$PATH"

                      if [ ! -e /var/lib/postgresql/postgresql.conf ]; then
                        initdb --auth=trust -D "$PGDATA"
                        echo host all all 172.0.0.0/8 trust >> /var/lib/postgresql/pg_hba.conf
                      fi
                      postgres -D "$PGDATA" -c listen_addresses="*" &
                      PID=$!

                      until pg_isready -h localhost -p 5432; do
                        sleep 1
                      done

                      psql <<HEREDOC
                        CREATE ROLE odoo WITH LOGIN;
                        CREATE DATABASE odoo OWNER odoo ENCODING 'utf8' TEMPLATE template0;
                        GRANT ALL PRIVILEGES ON DATABASE odoo TO odoo;
                      HEREDOC

                      wait $PID
                    ''
                  ];
                };
              }
            else
              pkgs.bash;

          defaultConfig = {
            database = {
              name = "odoo";
              port = 5432;
              allow_containerization = false;
              package = pkgs.postgresql_17;
            };

            dev.pythonPackages = [
              "debugpy"
              "openupgradelib"
              "pyls-memestra"
              "pylsp-mypy"
              "pylint-odoo"
              "python-lsp-server[all]"
              "python-lsp-black"
              "python-lsp-isort"
              "git+https://github.com/ddejong-therp/odoo-repl@master"
              # rope only supports python 3.7 and higher
            ]
            ++ (lib.optionals (python.majorVersion == 3 && python.minorVersion >= 7) [
              "pylsp-rope"
            ]);

            odooConfig.options = {
              db_host = if completeConfig.database.allow_containerization then "127.0.0.1" else "";
              db_user = if completeConfig.database.allow_containerization then "odoo" else "";
              db_port = completeConfig.database.port;
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
                commands = commands;
              }
            );
            build-addons = pkgs.writers.writeBashBin "build-addons" (
              import ./commands/build-addons.nix {
                config = config;
                lib = lib;
              }
            );
            build-config = pkgs.writers.writeBashBin "build-config" (
              import ./commands/build-config.nix {
                config = completeConfig;
                lib = lib;
              }
            );
            build-dev = pkgs.writers.writeBashBin "build-dev" (
              import ./commands/build-dev.nix {
                commands = commands;
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
                    config = completeConfig;
                    lib = lib;
                    pkgs = pkgs;
                  }
                );
            build-venv = pkgs.writers.writeBashBin "build-venv" (
              import ./commands/build-venv.nix {
                config = completeConfig;
                lib = lib;
                odooMajorVersion = odooMajorVersion;
                pkgs = pkgs;
                python = python;
                pythonPackages = pythonPackages;
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
                pkgs = pkgs;
                odooMajorVersion = odooMajorVersion;
              }
            );
            setup-dev = pkgs.writers.writeBashBin "setup-dev" (
              import ./commands/setup-dev.nix {
                config = completeConfig;
                lib = lib;
                odooMajorVersion = odooMajorVersion;
              }
            );
            shell = pkgs.writers.writeBashBin "shell" (
              import ./commands/shell.nix {
                odooMajorVersion = odooMajorVersion;
              }
            );
            upgrade = pkgs.writers.writeBashBin "upgrade" (
              import ./commands/upgrade.nix {
                odooMajorVersion = odooMajorVersion;
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
              basedpyright
              cyrus_sasl
              stdenv.cc.cc.lib
              git-aggregator
              libffi
              libjpeg
              libxcrypt-legacy
              libxml2
              libxslt
              openldap
              pkg-config
              python.package
              cargo
              rustc
              wget
              wkhtmltopdf
              yq
              zlib
            ])
            ++ [
              completeConfig.database.package.dev
            ];

          shellHook = with pkgs; ''
            alias python="${python.package}/bin/python${lib.versions.majorMinor python.version}"
            export PYTHONPATH="${python.package}/lib/site-packages"
            # Python 3.6 may fail if this environment variable is set to something
            unset _PYTHON_SYSCONFIGDATA_NAME
            export LD_LIBRARY_PATH="${
              lib.makeLibraryPath (
                [
                  stdenv.cc.cc.lib
                  libxcrypt-legacy
                ]
                # python-magic (odoo 19+) dlopen()s libmagic by bare name at import time; nix has
                # no traditional /usr/lib for it to find via ldconfig, so it needs to be on
                # LD_LIBRARY_PATH instead.
                ++ lib.optionals (odooMajorVersion >= 19) [ file ]
              )
            }"

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
                export CONTAINER_ID=$(docker container create -p ${toString completeConfig.database.port}:5432 --name "wax-$IMAGE_HASH" "$IMAGE_NAME")
              fi

              CONTAINER_ID_RUNNING=$(docker container ls -q -f "name=^wax-''${IMAGE_HASH}$")
              if [ "$CONTAINER_ID_RUNNING" != "$CONTAINER_ID" ]; then
                docker start -a "$CONTAINER_ID" >> wax/log/postgres.log 2>&1 &
                trap "docker container stop '$CONTAINER_ID' && echo Stopped Postgres container." EXIT
              fi
            fi

          '';
        };

    };
}
