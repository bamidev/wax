{ lib, config }:
''
  set -e
  cat > wax/odoo.cfg <<HEREDOC
  ${lib.generators.toINI { } config.odooConfig}
  HEREDOC
''
