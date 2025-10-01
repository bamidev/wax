{ odooMajorVersion, ... }:
''
  if [ ${toString odooMajorVersion} -lt 10 ]; then
    wax/venv/bin/python wax/repos/odoo/odoo.py -c wax/odoo.cfg ''$@
  else
    wax/venv/bin/python wax/repos/odoo/odoo-bin -c wax/odoo.cfg ''$@
  fi
''
