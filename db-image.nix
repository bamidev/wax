{
  pkgs,
  lib,
  config,
}:
pkgs.dockerTools.buildImage {
  name = "wax-postgres-image";

  contents =
    with pkgs;
    [
      bash
      coreutils
    ]
    ++ [
      config.database.package
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
        export PATH="${config.database.package}/bin:$PATH"

        if [ ! -e /var/lib/postgresql/postgresql.conf ]; then
          initdb --auth=trust -D "$PGDATA"
          echo host all all 0.0.0.0/0 trust >> /var/lib/postgresql/pg_hba.conf
        fi
        postgres -D "$PGDATA" -c listen_addresses="*" &
        PID=$!

        until pg_isready -h localhost -p 5432; do
          sleep 1
        done

        psql <<HEREDOC
          CREATE ROLE odoo WITH LOGIN;
          CREATE DATABASE ${config.database.name} OWNER odoo ENCODING 'utf8' TEMPLATE template0;
          GRANT ALL PRIVILEGES ON DATABASE ${config.database.name} TO odoo;
        HEREDOC

        wait $PID
      ''
    ];
  };
}
