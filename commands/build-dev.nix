{ commands, ... }: ''
  set -e
  ${commands.build}/bin/build
  ${commands.setup-dev}/bin/setup-dev
''
