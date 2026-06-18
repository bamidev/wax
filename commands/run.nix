{ pkgs, odooMajorVersion, ... }:
''
  CMD_PREFIX="${pkgs.expect}/bin/unbuffer wax/venv/bin/python wax/repos/odoo"
  CMD_POSTFIX="-c wax/odoo.cfg"
  if [ ${toString odooMajorVersion} -lt 8 ]; then
    $CMD_PREFIX/openerp-server $CMD_POSTFIX ''$@ 2>&1 | tee -a wax/log/odoo.log
  elif [ ${toString odooMajorVersion} -lt 10 ]; then
    $CMD_PREFIX/odoo.py $CMD_POSTFIX ''$@ 2>&1 | tee -a wax/log/odoo.log
  else
    $CMD_PREFIX/odoo-bin $CMD_POSTFIX  ''$@ 2>&1 | tee -a wax/log/odoo.log
  fi
''
