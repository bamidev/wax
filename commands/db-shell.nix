{ config }:
if config.database.name == null then
  ''
    echo You need to specify a database name before a database container can be created.
  ''
else
  ''
    ${config.database.package}/bin/psql -h 127.0.0.1 -p ${toString config.database.container_port} -U postgres ${config.database.name}
  ''
