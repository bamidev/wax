{ commands, ... }:
''
  set -e

  # Clean up tmp dir if it still exists
  rm -rf wax/tmp/*

  # Install virtual environment if needed
  ${commands.build-venv}/bin/build-venv

  # Update repos with git-aggregator
  echo Aggregating repositories...
  ${commands.build-repos}/bin/build-repos

  echo Linking addons...
  ${commands.build-addons}/bin/build-addons
  echo Generating odoo config...
  ${commands.build-config}/bin/build-config
  echo Done.
''
