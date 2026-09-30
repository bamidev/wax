{ pkgs, odooMajorVersion, ... }:
''
  set -euo pipefail

  CMD_PREFIX="wax/venv/bin/python wax/repos/odoo"
  CMD_POSTFIX="-c wax/odoo.cfg"
  if [ ${toString odooMajorVersion} -lt 8 ]; then
    BIN="$CMD_PREFIX/openerp-server"
  elif [ ${toString odooMajorVersion} -lt 10 ]; then
    BIN="$CMD_PREFIX/odoo.py"
  else
    BIN="$CMD_PREFIX/odoo-bin"
  fi

  ARGS=""
  if [ "$#" -gt 0 ]; then
    printf -v ARGS '%q ' "''$@"
  fi

  ${pkgs.util-linux}/bin/script -qefc "$BIN $CMD_POSTFIX $ARGS" /dev/null 2>&1 | tee -a wax/log/odoo.log
''
