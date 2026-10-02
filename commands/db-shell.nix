{ config }: ''
  ${config.database.package}/bin/psql -h 127.0.0.1 -p ${toString config.database.container_port} -U postgres ${config.database.name}
''
